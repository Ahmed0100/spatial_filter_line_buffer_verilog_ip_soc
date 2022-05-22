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


module convolution #(parameter PIXEL_SIZE=32)(
    input clk,
    input reset_n,
    input [(PIXEL_SIZE*9)-1:0] i_pixel_data,
    input i_pixel_data_valid,
    output reg [PIXEL_SIZE-1:0] o_convoluted_data,
    output reg o_convoluted_data_valid
    );

    integer i;
    reg [PIXEL_SIZE-1:0] kernel [8:0];

    reg [31:0] mult_data[8:0];

    reg mult_data_valid;
    
    reg [31:0] sum_data;
    reg sum_data_valid;
    
    initial 
    begin
        for(i=0;i<9;i=i+1)
        begin
            kernel[0] =  1;
        end
    end
    always @(posedge clk)
    begin
        for(i=0;i<9;i=i+1)
        begin
            mult_data[i]<=kernel[i]*i_pixel_data[i*PIXEL_SIZE+:PIXEL_SIZE];
        end
        mult_data_valid<=i_pixel_data_valid;
    end

    always @(posedge clk)
    begin
        sum_data<=mult_data[0]+mult_data[1]+mult_data[2]+
        mult_data[3]+mult_data[4]+mult_data[5]+
        mult_data[6]+mult_data[7]+mult_data[8];
      
        sum_data_valid <= mult_data_valid;
    end
    
    always @(posedge clk)
    begin
       o_convoluted_data <= sum_data/9;
       o_convoluted_data_valid <= sum_data_valid;
    end
endmodule