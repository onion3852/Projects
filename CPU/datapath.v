`timescale 1ns / 1ps

module datapath (
    input        clk,
    input [15:0] i_data,

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

    output [15:0] o_ir,
    output [15:0] o_data,
    output [11:0] o_addr,
    output        o_we_1,
    output        o_sel_we_1,
    output        o_ce,
    output        o_decoding,
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
reg [11:0] r_addr;
reg        r_we;
reg        r_ce;
reg        r_fetch;
reg        r_decoding;
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

    r_decoding <= 1'b0;
end

// Sequence Counter &
// i_fetch to r_fetch
always @ (*) begin
    if(run) begin
        SC = SC + 1;
    end
    else if(r_ex_done) begin
        run = 1'b0;
        SC  = 3'b0;

        r_w_mem_ref = 1'b0;
    end
    else begin
        SC = 3'b0;
    end

    r_fetch = r_decoding ? 1'b0 : i_fetch;
end

// Fetch Instruction & 
// Increasing PC & 
// IR gets the instruction code
always @ (posedge clk) begin
    if(r_fetch) begin
        AR <= PC;
        PC <= PC + 1;

        r_ce       <= 1'b0;
        r_ex_done  <= 1'b0;
        r_decoding <= 1'b1;
    end
    else if(!r_fetch && !r_ce) begin  // reading instruction from memory
        r_ce   <= 1'b1;
        r_we   <= 1'b0;
        r_addr <= AR;
    end
    else if(r_decoding && r_ce) begin
        IR <= i_data;
    end
end

// Core - Register reference instructions
always @ (posedge clk) begin
    if(i_clr_ac && i_execute) begin
        AC <= 16'b0;

        r_ex_done <= 1'b1;
    end
    else if(i_clr_e && i_execute) begin
        E  <= 1'b0;

        r_ex_done <= 1'b1;
    end
    else if(i_comp_ac && i_execute) begin
        AC <= ~AC;

        r_ex_done <= 1'b1;
    end
    else if(i_load_ac && i_execute) begin
        AC <= IR[7:0];

        r_ex_done <= 1'b1;
    end
    else if(i_cir_r && i_execute) begin
        AC[15] <= E;
        AC     <= (AC >> 1);
        E      <= AC[0];

        r_ex_done <= 1'b1;
    end
    else if(i_cir_l && i_execute) begin
        AC[0] <= E;
        AC    <= (AC << 1);
        E     <= AC[15];

        r_ex_done <= 1'b1;
    end
    else if(i_inc_ac && i_execute) begin
        AC <= AC + 1;

        r_ex_done <= 1'b1;
    end
end

// Memory reference instructions - SC == 3'b1
always @ (posedge clk) begin
    if(i_is_ind) begin
        IR[11:0]    <= i_data;
        AR          <= i_data;
        run         <= 1'b1;
        r_w_mem_ref <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_add && (SC == 3'd1)) begin
        DR <= i_data;
    end
    else if(i_is_dir && i_execute && i_load && (SC == 3'd1)) begin
        DR <= i_data;
    end
    else if(i_is_dir && i_execute && i_store && (SC == 3'd1)) begin
        r_data    <= DR;
        r_addr    <= AR;
        r_we      <= 1'b1;
        r_ex_done <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_branch && (SC == 3'd1)) begin
        PC        <= AR;
        r_ex_done <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_isz && (SC == 3'd1)) begin
        DR <= i_data;
    end
end

// Memory reference instructions - SC is bigger than 3'b1
always @ (posedge clk) begin
    if(i_is_dir && i_execute && i_add && (SC == 3'd2)) begin
        {E, AC}   <= AC + DR;
        r_ex_done <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_load && (SC == 3'd2)) begin
        AC        <= DR;
        r_ex_done <= 1'b1;
    end
    else if(i_is_dir && i_execute && i_isz && (SC == 3'd2)) begin
        DR <= DR + 1;
    end
    else if(i_is_dir && i_execute && i_isz && (SC == 3'd3)) begin
        r_data <= DR;
        r_addr <= AR;
        r_we   <= 1'b1;

        if(DR == 16'b0) begin
            PC <= PC + 1;
        end
        r_ex_done <= 1'b1;
    end
end

assign o_ir        = IR;
assign o_data      = r_data;
assign o_addr      = r_addr;
assign o_we_1      = r_we;
assign o_sel_we_1  = (!r_ex_done || i_is_dir);  // select o_we_1
assign o_ce        = r_ce;
assign o_decoding  = r_decoding;
assign o_ex_done   = r_ex_done;
assign o_w_mem_ref = r_w_mem_ref;

endmodule


// 1틱 signal 만드는 방법이 있나???

// 한 instruction cycle이 끝나면 
// 각종 control signal들을 low로 만드는 부분이 필요함