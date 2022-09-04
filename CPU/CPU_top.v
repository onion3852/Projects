`timescale 1ns / 1ps

module CPU #(
    parameter DWIDTH 16,
    parameter ADDR_WIDTH 12
)   (
    input clk,
    input reset_n
    );


// instantiation
datapath DATAPATH ();
control_unit CONTROL ();