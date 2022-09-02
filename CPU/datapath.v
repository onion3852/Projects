`timescale 1ns / 1ps

module datapath (
    input clk,

    input i_read,
    input i_write,

    input i_clr_ac,
    input i_clr_e,
    input i_comp_ac,
    input i_load_ac,
    input i_cir_r,
    input i_cir_l,
    input i_inc_ac,

    input i_add,
    input i_load,
    input i_store,
    input i_branch,
    input i_isz,

    input i_clr_reg
    );
    
//parameter DWIDTH 16;
//parameter ADDR_WIDTH 12;

reg [15:0] IR;
reg [15:0] DR;
reg [15:0] AC;              
reg [11:0] AR;
reg [11:0] PC;
reg        I;  // flip-flop I ( = IR[15] )
reg        E;  // flip-flop E

// Reset
always @ (i_clr_reg) begin
    IR <= 16'b0;
    DR <= 16'b0;
    AC <= 16'b0;
    AR <= 12'b0;
    PC <= 12'b0;
    E  <= 1'b0;
    I  <= 1'b0;
end

// Core - Register reference instructions
always @ (posedge clk) begin
    if(i_clr_ac) begin
        AC <= 16'b0;
    end
    else if(i__clr_e) begin
        E  <= 1'b0;
    end
    else if(i_comp_ac) begin
        AC <= ~AC;
    end
    else if(i_load_ac) begin
        AC <= IR[7:0];
    end
    else if(i_cir_r) begin
        AC     <= (AC >> 1);
        AC[15] <= E;
        E      <= AC[0];
    end
    else if(i_cir_l) begin
        AC    <= (AC << 1);
        AC[0] <= E;
        E     <= AC[15];
    end
    else if(i_inc_ac) begin
        AC <= AC + 1;
    end
end






endmodule