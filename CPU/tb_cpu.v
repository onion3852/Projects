`timescale 1ns / 1ps

module tb_cpu ();

parameter ADDR_WIDTH = 12;
parameter WORD_DEPTH = 4096;
parameter WORD_WIDTH = 16;

reg CLK, RESET_n;

wire [WORD_WIDTH-1:0] DATA_R;
wire [WORD_WIDTH-1:0] DATA_W;
wire [ADDR_WIDTH-1:0] ADDR;
wire WE;

integer file_pointer;
integer i;

CPU CPU (
    .clk(CLK), 
    .reset_n(RESET_n)
    );

sram SRAM (
    .clk(CLK), 
    .i_data(DATA_W), 
    .i_addr(ADDR), 
    .i_we(WE), 
    .o_data(DATA_R)
    );

always #5 CLK = ~CLK;
initial begin
    CLK = 1'b0;
    RESET_n = 1'b1; #1  RESET_n = 1'b0; #1
    RESET_n = 1'b1;
    
    $readmemb("score.txt", tb_cpu.SRAM.mem, 100, 109);
    $readmemb("instruction.txt", tb_cpu.SRAM.mem);
    file_pointer = $fopen("result.txt");
    
    #2530
    $fdisplay(file_pointer, "Sum is %3d", tb_cpu.SRAM.mem[99]);
    $fclose(file_pointer);
    $finish;
end

endmodule