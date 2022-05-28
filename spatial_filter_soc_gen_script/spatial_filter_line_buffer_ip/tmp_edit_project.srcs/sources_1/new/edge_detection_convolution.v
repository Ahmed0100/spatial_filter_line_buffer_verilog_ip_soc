`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: edge_detection_convolution
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module edge_detection_convolution #(parameter PIXEL_SIZE = 32)(
    input clk,
    input reset_n,
    input [(PIXEL_SIZE*9)-1:0] i_pixel_data,
    input i_pixel_data_valid,
    output reg [PIXEL_SIZE-1:0] o_convoluted_data,
    output reg o_convoluted_data_valid
    );

    integer i;
    reg [PIXEL_SIZE-1:0] kernel_x [8:0];
    reg [PIXEL_SIZE-1:0] kernel_y [8:0];

    reg [31:0] mult_data_x[8:0];
    reg [31:0] mult_data_y[8:0];

    reg mult_data_valid;
    
    reg [31:0] sum_data_x;
    reg [31:0] sum_data_y;
    reg sum_data_valid;
    
    reg [31:0] convoluted_data_x,convoluted_data_y;
    wire [31:0] convoluted_data;
    reg convoluted_data_valid;
 
    initial 
    begin
            kernel_x[0] =  1;
            kernel_x[1] =  0;
            kernel_x[2] = -1;
            kernel_x[3] =  2;
            kernel_x[4] =  0;
            kernel_x[5] = -2;
            kernel_x[6] =  1;
            kernel_x[7] =  0;
            kernel_x[8] = -1;
            
            kernel_y[0] =  1;
            kernel_y[1] =  2;
            kernel_y[2] =  1;
            kernel_y[3] =  0;
            kernel_y[4] =  0;
            kernel_y[5] =  0;
            kernel_y[6] = -1;
            kernel_y[7] = -2;
            kernel_y[8] = -1;
    end
    always @(posedge clk)
    begin
        for(i=0;i<9;i=i+1)
        begin
            mult_data_x[i]<=$signed(kernel_x[i])*$signed({1'b0,i_pixel_data[i*PIXEL_SIZE+:PIXEL_SIZE]});
            mult_data_y[i]<=$signed(kernel_y[i])*$signed({1'b0,i_pixel_data[i*PIXEL_SIZE+:PIXEL_SIZE]});
        end
        mult_data_valid<=i_pixel_data_valid;
    end

    always @(posedge clk)
    begin
        sum_data_x<=$signed(mult_data_x[0])+$signed(mult_data_x[1])+$signed(mult_data_x[2])+
        $signed(mult_data_x[3])+$signed(mult_data_x[4])+$signed(mult_data_x[5])+
        $signed(mult_data_x[6])+$signed(mult_data_x[7])+$signed(mult_data_x[8]);
       
        sum_data_y<=$signed(mult_data_y[0])+$signed(mult_data_y[1])+$signed(mult_data_y[2])+
        $signed(mult_data_y[3])+$signed(mult_data_y[4])+$signed(mult_data_y[5])+
        $signed(mult_data_y[6])+$signed(mult_data_y[7])+$signed(mult_data_y[8]);
        sum_data_valid <= mult_data_valid;
    end
    always @(posedge clk)
    begin
        convoluted_data_x <= $signed(sum_data_x)*$signed(sum_data_x);
        convoluted_data_y <= $signed(sum_data_y)*$signed(sum_data_y);
        convoluted_data_valid <= sum_data_valid;
    end
    assign convoluted_data = convoluted_data_x+convoluted_data_y;
    
    always @(posedge clk)
    begin
        if(convoluted_data>5000)
            o_convoluted_data <= 32'hff;
        else 
            o_convoluted_data <= 32'h0;    
        o_convoluted_data_valid <= convoluted_data_valid;
    end
endmodule