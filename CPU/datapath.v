`timescale 1ns / 1ps

module datapath (
    input        clk,
    input [15:0] i_data,

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

    input i_clr_reg,
    input i_fetch,
    input i_execute,
    input i_is_ind,
    input i_is_dir,

    output        o_ex_done
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

reg r_ex_done;

// Reset
always @ (posedge i_clr_reg) begin
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
    if(i_clr_ac && i_execute) begin
        AC <= 16'b0;
    end
    else if(i__clr_e && i_execute) begin
        E  <= 1'b0;
    end
    else if(i_comp_ac && i_execute) begin
        AC <= ~AC;
    end
    else if(i_load_ac && i_execute) begin
        AC <= IR[7:0];
    end
    else if(i_cir_r && i_execute) begin
        AC[15] <= E;
        AC     <= (AC >> 1);
        E      <= AC[0];
    end
    else if(i_cir_l && i_execute) begin
        AC[0] <= E;
        AC    <= (AC << 1);
        E     <= AC[15];
    end
    else if(i_inc_ac && i_execute) begin
        AC <= AC + 1;
    end
    r_ex_done <= 1'b1;
end

// Core - Memory reference instructions
always @ (posedge clk) begin
    if(i_is_ind) begin
        IR[11:0] <= i_data;
        AR       <= i_data;
    end
    else if(i_is_dir) begin
        
    end
end


assign o_ex_done = r_ex_done;


endmodule