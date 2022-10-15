`timescale 1ns/1ps

module sram_16x8 #(
    parameter ADDR_WIDTH = 4,
    parameter WORD_DEPTH = 16,
    parameter WORD_WIDTH = 8
)   (
    input [ADDR_WIDTH-1:0] addr,
    input [WORD_WIDTH-1:0] din,
    input                  clk,
    input                  we,

    output [WORD_WIDTH-1:0] dout
    );

reg [WORD_WIDTH-1:0] mem [0:WORD_DEPTH-1];
reg [WORD_WIDTH-1:0] dout;

// write
always @ (posedge clk) begin
    if(!we) begin
        mem[addr] <= din[WORD_WIDTH-1:0];
    end
end

// read
always @ (posedge clk) begin
    if(we) begin
        #1
        dout <= mem[addr];
    end
end
    
endmodule