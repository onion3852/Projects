`timescale 1ns / 1ps

module tb_cpu();

reg CLK, RESET;
wire [11:0] ADDR_BUS;    // address bus
wire [15:0] DATA_BUS_1;  // cpu to sram
wire [15:0] DATA_BUS_2;  // sram to cpu
wire WE;                 // write enable

integer file_pointer;
integer i;

cpu CPU (.clk(CLK), .reset(RESET), .data_in(DATA_BUS_2), .addr(ADDR_BUS), .we(WE), .data_out(DATA_BUS_1));
sram SRAM (.clk(CLK), .din(DATA_BUS_1), .addr(ADDR_BUS), .we(WE), .dout(DATA_BUS_2));

always #5 CLK = ~CLK;
initial begin
    CLK = 1'b0;
    RESET = 1'b1; #1  RESET = 1'b0; #1
    RESET = 1'b1;
    
    $readmemb("score.txt", tb_cpu.SRAM.mem, 100, 109);
    $readmemb("instruction.txt", tb_cpu.SRAM.mem);
    file_pointer = $fopen("result.txt");
    
    #2530
    $fdisplay(file_pointer, "Sum is %3d", tb_cpu.SRAM.mem[99]);
    $fclose(file_pointer);
    $finish;
end

endmodule