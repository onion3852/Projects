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

    output [15:0] o_data,
    output        o_write,
    output        o_ex_done,
    output        o_w_mem_ref
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
reg [2:0]  SC; // Sequence Counter 
               // memory reference execution에서 
               // 어쩔 수 없이 필요한 듯

reg [15:0] r_data;
reg        r_write;
reg        r_ex_done;
reg        r_w_mem_ref;
reg        run;

// Reset
always @ (posedge i_clr_reg) begin
    IR <= 16'b0;
    DR <= 16'b0;
    AC <= 16'b0;
    AR <= 12'b0;
    PC <= 12'b0;
    E  <= 1'b0;
    I  <= 1'b0;
    SC <= 3'b0;
end

// Sequence Counter
always @ (*) begin
    if(run) begin
        SC = SC + 1;
    end
    else if(r_ex_done) begin
        run = 1'b0;
        SC  = 3'b0;
    end
    else begin
        SC = 3'b0;
    end
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

// Memory reference instructions - SC == 3'b1
always @ (posedge clk) begin
    if(i_is_ind) begin
        IR[11:0]    <= i_data;
        AR          <= i_data;
        run         <= 1'b1;
        r_w_mem_ref <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_add && (SC == 3'b1)) begin
        DR <= i_data;
    end
    else if(i_is_dir && i_execute && i_load && (SC == 3'b1)) begin
        DR <= i_data;
    end
    else if(i_is_dir && i_execute && i_store && (SC == 3'b1)) begin
        r_data    <= DR;
        r_addr    <= AR;
        r_write   <= 1'b1;
        r_ex_done <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_branch && (SC == 3'b1)) begin
        PC        <= AR;
        r_ex_done <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_isz && (SC == 3'b1)) begin
        DR <= i_data;
    end
end

// Memory reference instructions - SC is bigger than 3'b1
always @ (posedge clk) begin
    if(i_is_dir && i_execute && i_add && (SC == 3'b2)) begin
        {E, AC}   <= AC + DR;
        r_ex_done <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_load && (SC == 3'b2)) begin
        AC        <= DR;
        r_ex_done <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_isz && (SC == 3'b2)) begin
        DR <= DR + 1;
    end
    else if(i_is_dir && i_execute && i_isz && (SC == 3'b3)) begin
        r_data  <= DR;
        r_addr  <= AR;
        r_write <= 1'b1;

        if(DR == 16'b0) begin
            PC <= PC + 1;
        end

        r_ex_done <= 1'b1;
    end
end

assign o_data      = r_data;
assign o_write     = r_write;
assign o_ex_done   = r_ex_done;
assign o_w_mem_ref = r_w_mem_ref;

endmodule