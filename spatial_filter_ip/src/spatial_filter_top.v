`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: spatial_filter_top
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
module spatial_filter_top(
input axis_clk,
input axis_reset_n,

//slave
input i_s_data_valid,
input [7:0] i_s_data,
output o_s_ready,

//master
output o_m_data_valid,
output [7:0] o_m_data,
input i_m_ready,
//intr
output o_intr
    );
    parameter IMAGE_WIDTH = 512;
    wire [71:0] pixel_data;
    wire pixel_data_valid;
    
    wire [7:0] conv_data;
    wire conv_data_valid;
    wire axis_full;
    assign o_s_ready = ! axis_full;
    line_buffers_control #(.IMAGE_WIDTH(IMAGE_WIDTH)) line_buffers_control_inst (
        .clk(axis_clk),
        .reset_n(axis_reset_n),
        .i_pixel_data(i_s_data),
        .i_pixel_data_valid(i_s_data_valid),
        .o_pixel_data(pixel_data),
        .o_pixel_data_valid(pixel_data_valid),
        .o_intr(o_intr)
      );
      
    edge_detection_convolution edge_detection_conv_inst(
         .clk(axis_clk),
         .reset_n(axis_reset_n),
         .i_pixel_data(pixel_data),
         .i_pixel_data_valid(pixel_data_valid),
         .o_convoluted_data(conv_data),
         .o_convoluted_data_valid(conv_data_valid)
     );
    fifo_generator_0 fifo_generator_0_inst (
       .wr_rst_busy(),        // output wire wr_rst_busy
       .rd_rst_busy(),        // output wire rd_rst_busy
       .s_aclk(axis_clk),                  // input wire s_aclk
       .s_aresetn(axis_reset_n),            // input wire s_aresetn
       .s_axis_tvalid(conv_data_valid),    // input wire s_axis_tvalid
       .s_axis_tready(),    // output wire s_axis_tready
       .s_axis_tdata(conv_data),      // input wire [7 : 0] s_axis_tdata
       .m_axis_tvalid(o_m_data_valid),    // output wire m_axis_tvalid
       .m_axis_tready(i_m_ready),    // input wire m_axis_tready
       .m_axis_tdata(o_m_data),      // output wire [7 : 0] m_axis_tdata
       .axis_prog_full(axis_full)  // output wire axis_prog_full
     );

endmodule
