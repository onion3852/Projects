`timescale 1ns / 1ps

module tb_cpu();

reg CLK, RESET_n;

integer file_pointer;
integer i;

cpu CPU (
    .clk(CLK), 
    .reset(RESET_n),
    );

sram SRAM (
    .clk(CLK)
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