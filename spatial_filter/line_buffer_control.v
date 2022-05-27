`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: line_buffers_control
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


module line_buffers_control #(parameter PIXEL_SIZE = 32, parameter IMAGE_WIDTH = 512)(
input clk,
input reset_n,
input [PIXEL_SIZE-1:0] i_pixel_data,
input i_pixel_data_valid,
output reg [(PIXEL_SIZE*9)-1:0] o_pixel_data,
output o_pixel_data_valid,
output reg o_intr
    );
    localparam PTR_WIDTH = $clog2(IMAGE_WIDTH);
    localparam TOTAL_LINES_PIXELS_BIT_WIDTH = $clog2((IMAGE_WIDTH*4));
    localparam INTR_DURATION = 500;
 
    reg [TOTAL_LINES_PIXELS_BIT_WIDTH-1:0] total_line_buffers_pixels_count;
    reg [3:0] line_buffer_data_valid;
    wire [(PIXEL_SIZE*3)-1:0] line_buffer_data_0;
    wire [(PIXEL_SIZE*3)-1:0] line_buffer_data_1;
    wire [(PIXEL_SIZE*3)-1:0] line_buffer_data_2;
    wire [(PIXEL_SIZE*3)-1:0] line_buffer_data_3;
    reg [3:0] line_buffer_data_rd_en;
    
    reg [PTR_WIDTH-1:0] line_buffer_wr_pixel_ctr;
    reg [PTR_WIDTH-1:0] line_buffer_rd_pixel_ctr;

    reg [1:0] current_wr_line_buffer_index;
    reg [1:0] current_rd_line_buffer_index;
    reg[1:0] current_state;
    reg line_buffers_rd_en;

    reg [31:0] intr_count;
    localparam IDLE='d0,
               READ='d1,
               INTR_DELAY='d2;
  
    assign o_pixel_data_valid=line_buffers_rd_en;
  
    always @(posedge clk)
    begin
        if(!reset_n)
            total_line_buffers_pixels_count<=0;
        else 
           if(i_pixel_data_valid && !line_buffers_rd_en)
              total_line_buffers_pixels_count<=total_line_buffers_pixels_count+1;
           else if(!i_pixel_data_valid && line_buffers_rd_en)
              total_line_buffers_pixels_count<=total_line_buffers_pixels_count-1;
    end
    
    always @(posedge clk)
    begin
        if(!reset_n)
        begin
            current_state<=IDLE;
            line_buffers_rd_en <= 0;
            o_intr<=0;
            intr_count<=0;
        end
        else 
        begin
            case(current_state)
                IDLE:
                begin
                    o_intr<=0;
                    if(total_line_buffers_pixels_count>=(3*IMAGE_WIDTH))
                    begin
                        current_state<=READ;
                        line_buffers_rd_en<=1;
                    end
                end
                READ:
                begin
                    if(line_buffer_rd_pixel_ctr==IMAGE_WIDTH-1)
                    begin
                        current_state<=INTR_DELAY;
                        o_intr<=1;
                        line_buffers_rd_en<=0; 
                    end
                end
                INTR_DELAY:
                begin
                    line_buffers_rd_en<=0;
                    o_intr<=1;
                    if(intr_count == INTR_DURATION)
                    begin
                        intr_count<=0;
                        current_state<=IDLE;
                    end
                    else
                        intr_count<=intr_count+1;
                end
            endcase
        end
        
    end
    always @(posedge clk)
    begin
        if(!reset_n)
            line_buffer_wr_pixel_ctr<=0;
        else if(i_pixel_data_valid)
        begin
            if(line_buffer_wr_pixel_ctr==IMAGE_WIDTH-1)
                line_buffer_wr_pixel_ctr<=0;
            else
                line_buffer_wr_pixel_ctr<=line_buffer_wr_pixel_ctr+1;
        end
    end

    always @(posedge clk)
    begin
        if(!reset_n)
            current_wr_line_buffer_index<=0;
        else if(line_buffer_wr_pixel_ctr==IMAGE_WIDTH-1 && i_pixel_data_valid)
            if(current_wr_line_buffer_index==3)
                current_wr_line_buffer_index<=0;
            else 
                current_wr_line_buffer_index<=current_wr_line_buffer_index+1;
    end

    always @(*)
    begin
        line_buffer_data_valid = 0;
        line_buffer_data_valid[current_wr_line_buffer_index]=i_pixel_data_valid;
    end
 
    always @(posedge clk)
    begin
        if(!reset_n)
            line_buffer_rd_pixel_ctr<=0;
        else if(line_buffers_rd_en)
            if(line_buffer_rd_pixel_ctr == IMAGE_WIDTH-1)
                line_buffer_rd_pixel_ctr <= 0;
            else 
                line_buffer_rd_pixel_ctr <= line_buffer_rd_pixel_ctr+1;
    end
    always @(posedge clk)
    begin
        if(!reset_n)
            current_rd_line_buffer_index<=0;
        else if(line_buffer_rd_pixel_ctr== IMAGE_WIDTH-1 && line_buffers_rd_en)
            if(current_rd_line_buffer_index == 3)
                current_rd_line_buffer_index <=0;
            else
                current_rd_line_buffer_index<=current_rd_line_buffer_index+1;
    end
    always @(*)
    begin
        case(current_rd_line_buffer_index)
            0: o_pixel_data={line_buffer_data_2,line_buffer_data_1,line_buffer_data_0};
            1: o_pixel_data={line_buffer_data_3,line_buffer_data_2,line_buffer_data_1};
            2: o_pixel_data={line_buffer_data_0,line_buffer_data_3,line_buffer_data_2};
            3: o_pixel_data={line_buffer_data_1,line_buffer_data_0,line_buffer_data_3};
            default: o_pixel_data={line_buffer_data_2,line_buffer_data_1,line_buffer_data_0};
        endcase
    end
    always @(*)
    begin
        case(current_rd_line_buffer_index)
            0:
            begin
                line_buffer_data_rd_en[0]=line_buffers_rd_en;
                line_buffer_data_rd_en[1]=line_buffers_rd_en;
                line_buffer_data_rd_en[2]=line_buffers_rd_en;
                line_buffer_data_rd_en[3]=0;
            end
            1:
            begin
                line_buffer_data_rd_en[0]=0;
                line_buffer_data_rd_en[1]=line_buffers_rd_en;
                line_buffer_data_rd_en[2]=line_buffers_rd_en;
                line_buffer_data_rd_en[3]=line_buffers_rd_en;
            end
            2:
            begin
                line_buffer_data_rd_en[0]=line_buffers_rd_en;
                line_buffer_data_rd_en[1]=0;
                line_buffer_data_rd_en[2]=line_buffers_rd_en;
                line_buffer_data_rd_en[3]=line_buffers_rd_en;
            end
            3:
            begin
                line_buffer_data_rd_en[0]=line_buffers_rd_en;
                line_buffer_data_rd_en[1]=line_buffers_rd_en;
                line_buffer_data_rd_en[2]=0;
                line_buffer_data_rd_en[3]=line_buffers_rd_en;
            end
            default:
            begin
                line_buffer_data_rd_en[0]=line_buffers_rd_en;
                line_buffer_data_rd_en[1]=line_buffers_rd_en;
                line_buffer_data_rd_en[2]=line_buffers_rd_en;
                line_buffer_data_rd_en[3]=0;
            end
    endcase
    end
    line_buffer #(.IMAGE_WIDTH(IMAGE_WIDTH), .PIXEL_SIZE(PIXEL_SIZE)) line_buffer_inst0(
        .clk(clk),
        .reset_n(reset_n),
        .i_data(i_pixel_data),
        .i_data_valid(line_buffer_data_valid[0]),
        .o_data(line_buffer_data_0),
        .i_data_rd(line_buffer_data_rd_en[0])
     );
    line_buffer #(.IMAGE_WIDTH(IMAGE_WIDTH), .PIXEL_SIZE(PIXEL_SIZE)) line_buffer_inst1(
         .clk(clk),
         .reset_n(reset_n),
         .i_data(i_pixel_data),
         .i_data_valid(line_buffer_data_valid[1]),
         .o_data(line_buffer_data_1),
         .i_data_rd(line_buffer_data_rd_en[1])
      );
    line_buffer #(.IMAGE_WIDTH(IMAGE_WIDTH), .PIXEL_SIZE(PIXEL_SIZE)) line_buffer_inst2(
          .clk(clk),
          .reset_n(reset_n),
          .i_data(i_pixel_data),
          .i_data_valid(line_buffer_data_valid[2]),
          .o_data(line_buffer_data_2),
          .i_data_rd(line_buffer_data_rd_en[2])
       );
    line_buffer #(.IMAGE_WIDTH(IMAGE_WIDTH), .PIXEL_SIZE(PIXEL_SIZE)) line_buffer_inst3(
           .clk(clk),
           .reset_n(reset_n),
           .i_data(i_pixel_data),
           .i_data_valid(line_buffer_data_valid[3]),
           .o_data(line_buffer_data_3),
           .i_data_rd(line_buffer_data_rd_en[3])
        );
endmodule
