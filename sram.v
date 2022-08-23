`timescale 1ns / 1ps

module sram(dout, din, addr, we, clk);

parameter
    addr_width = 12, word_depth = 4096, word_width =16;

input [word_width-1:0]din;
input [addr_width-1:0 ]addr;
input we, clk;
output [word_width-1:0]dout;

reg [word_width-1:0]dout;
reg [word_width-1:0]mem[0:word_depth-1];    // 2^12 X 16 sram

always @ (posedge clk) begin
    #1
    if(!we) begin   // write
        mem[addr] <= din[word_width-1:0];
    end
    else if(we)     // read
        dout <= mem[addr];
end

endmodule