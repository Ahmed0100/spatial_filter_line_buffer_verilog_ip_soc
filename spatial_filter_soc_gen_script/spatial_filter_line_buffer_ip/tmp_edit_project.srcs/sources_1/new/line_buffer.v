`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: line_buffer
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


module line_buffer #(parameter PIXEL_SIZE = 32, parameter IMAGE_WIDTH = 512)(
input clk,
input reset_n,
input [PIXEL_SIZE-1:0] i_data,
input i_data_valid,
output [(PIXEL_SIZE*3)-1:0] o_data,
input i_data_rd
    );
    localparam PTR_WIDTH = $clog2(IMAGE_WIDTH);
    
    reg [PIXEL_SIZE-1:0] line [IMAGE_WIDTH-1:0];
    
    reg [PTR_WIDTH-1:0] rd_ptr;
    reg [PTR_WIDTH-1:0] wr_ptr;
    
    always @(posedge clk)
    begin
        if(i_data_valid)
            line[wr_ptr]<=i_data;
    end
    always @(posedge clk)
    begin
        if(!reset_n)
            wr_ptr<=0;
        else if(i_data_valid)
            if(wr_ptr==IMAGE_WIDTH-1)
                wr_ptr<=0;
            else
                wr_ptr<=wr_ptr+1;
    end
    assign o_data={line[rd_ptr],line[rd_ptr+1],line[rd_ptr+2]};
    
    always @(posedge clk)
    begin
        if(!reset_n)
            rd_ptr<=0;
        else if(i_data_rd)
            if(rd_ptr==IMAGE_WIDTH-1)
                rd_ptr<=0;
            else
                rd_ptr<=rd_ptr+1;
    end
endmodule