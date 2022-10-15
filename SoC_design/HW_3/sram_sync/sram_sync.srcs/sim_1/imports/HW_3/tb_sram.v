`timescale 1ns/1ps

module tb_sram ();

parameter ADDR_WIDTH = 4;
parameter WORD_DEPTH = 16;
parameter WORD_WIDTH = 8;

reg [ADDR_WIDTH-1:0] ADDR;
reg [WORD_WIDTH-1:0] DIN;
reg                  CLK;
reg                  WE;

integer i;

sram_16x8 SRAM (
    .addr(ADDR),
    .din (DIN),
    .clk (CLK),
    .we  (WE)
    );

always #5 CLK = ~CLK;
initial begin
    CLK = 1'b0;
    #2

    // write
    WE = 1'b0;
    for(i = 0; i < WORD_DEPTH; i = i + 1) begin
       ADDR = i;
       DIN  = i;
       #10;
    end

    // read
    WE = 1'b1;
    for(i = 0; i < WORD_DEPTH; i = i + 1) begin
        ADDR = i;
        #10;
    end
    
    #10
    $finish;
end

endmodule