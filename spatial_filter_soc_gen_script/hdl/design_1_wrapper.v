//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
//Date        : Sat May 28 11:50:27 2022
//Host        : DESKTOP-93BQQJR running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (Clk,
    reset_rtl,
    uart_rtl_rxd,
    uart_rtl_txd);
  input Clk;
  input reset_rtl;
  input uart_rtl_rxd;
  output uart_rtl_txd;

  wire Clk;
  wire reset_rtl;
  wire uart_rtl_rxd;
  wire uart_rtl_txd;

  design_1 design_1_i
       (.Clk(Clk),
        .reset_rtl(reset_rtl),
        .uart_rtl_rxd(uart_rtl_rxd),
        .uart_rtl_txd(uart_rtl_txd));
endmodule
