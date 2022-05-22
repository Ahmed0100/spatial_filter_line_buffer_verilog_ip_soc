`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// // Design Name: 
// Module Name: tb
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
`define IMG_HEADER_SIZE 1080
`define IMAGE_WIDTH 512
`define IMG_SIZE 512*512

module tb(

    );
   reg clk;
   reg reset_n;
   integer i,file1,file2,file3;
   reg [31:0] img_data_in=0;
   reg img_data_in_valid;
   integer data_sent_size=0,data_received_size=0;
   wire [31:0] img_data_out;
   wire img_data_out_valid;
   wire intr;
   
   initial
   begin
    clk=0;
    forever
    begin
        #5 clk=!clk;
    end
   end
   initial
   begin
        reset_n = 0;
        #100 reset_n=1;
        data_sent_size=0;
        img_data_in_valid=0;
        //file1=$fopen("lena_50x50px.bmp","rb");
      file1=$fopen("lena.bmp","rb");

        file2=$fopen("lena_out.bmp","wb");
        file3=$fopen("img_data.h","w");
        
        for(i=0;i<`IMG_HEADER_SIZE;i=i+1)
        begin
            $fscanf(file1,"%c",img_data_in[7:0]);
            $fwrite(file2,"%c",img_data_in);
        end
        //send first 4 lines of image
        for(i=0;i<4*`IMAGE_WIDTH;i=i+1)
        begin
            @(posedge clk);
            $fscanf(file1,"%c",img_data_in[7:0]);
            $fwrite(file3,"%0d,",img_data_in);
            img_data_in_valid=1;
        end
        data_sent_size=4*`IMAGE_WIDTH;
        @(posedge clk);
        img_data_in_valid=0;
        while(data_sent_size<`IMG_SIZE)
        begin
            //wait until any line buffer is ready to be written on
            @(posedge intr);
            for(i=0;i<`IMAGE_WIDTH;i=i+1)
            begin
                @(posedge clk);
                $fscanf(file1,"%c",img_data_in[7:0]);
                $fwrite(file3,"%0d,",img_data_in);
                img_data_in_valid=1;
            end
            @(posedge clk);
            img_data_in_valid=0;
            data_sent_size = data_sent_size+`IMAGE_WIDTH;
        end
//        @(posedge clk);
//        img_data_in_valid=0;
        //send 2 dummy lines
        @(posedge intr);
        for(i=0;i<`IMAGE_WIDTH;i=i+1)
        begin
            @(posedge clk);
            img_data_in =0;
            $fwrite(file3,"%0d,",img_data_in);
            img_data_in_valid=1;
        end
        @(posedge clk);
        img_data_in_valid=0;
        @(posedge intr);
        for(i=0;i<`IMAGE_WIDTH;i=i+1)
        begin
            @(posedge clk);
            img_data_in =0;
            $fwrite(file3,"%0d,",img_data_in);
            img_data_in_valid=1;
        end
        @(posedge clk);
        img_data_in_valid=0;
        $fclose(file1);
        $fclose(file3);
   end
 
 always @(posedge clk)
 begin
    if(img_data_out_valid)
    begin
        $fwrite(file2,"%c",img_data_out);
        data_received_size = data_received_size+1;
    end
    if(data_received_size == `IMG_SIZE)
    begin
        $fclose(file2);
        $stop;
    end
 end
  spatial_filter_top #( .IMAGE_WIDTH(`IMAGE_WIDTH)) dut(
    .axis_clk(clk),
    .axis_reset_n(reset_n),
    .i_s_data_valid(img_data_in_valid),
    .i_s_data(img_data_in),
    .o_s_ready(),
    .o_m_data_valid(img_data_out_valid),
    .o_m_data(img_data_out),
    .i_m_ready(1'b1),
    .o_intr(intr)
);   

endmodule