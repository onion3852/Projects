`timescale 1ns / 1ps

module control_unit(
    input        clk,
    input        reset_n,
    input        i_w_mem_ref,
    input        i_decoding,
    input        i_ex_done,
    input [15:0] ir,

    output [11:0] o_addr,
    output        o_we_2,
    output        o_ce,

    output       o_clr_ac,
    output       o_clr_e,
    output       o_comp_ac,
    output       o_load_ac,
    output       o_cir_r,
    output       o_cir_l,
    output       o_inc_ac,

    output       o_add,
    output       o_load,
    output       o_store,
    output       o_branch,
    output       o_isz,

    output       o_clr_reg,
    output       o_fetch,
    output       o_execute,
    output       o_is_ind,
    output       o_is_dir
    );

//parameter DWIDTH 16;
//parameter ADDR_WIDTH 12;

// state for FSM
localparam IDLE        = 3'd0;
localparam FETCH       = 3'd1;
localparam DECODE      = 3'd2;
localparam REG_REF     = 3'd3;
localparam MEM_REF_IND = 3'd4;  // indirect addressing
localparam MEM_REF     = 3'd5;
localparam DONE        = 3'd6;
reg [2:0] c_state;
reg [2:0] n_state;

wire is_ind;      // triggering MEM_REF_IND
wire is_mem_ref;  // triggering MEM_REF
wire is_reg_ref;  // triggering REG_REF
wire is_done;     // triggering DONE
wire is_fetch;    // triggering FETCH
wire is_decode;   // triggering DECODE

wire w_mem_ref = !reset_n ? 1'b0 : (!ir[15] && (ir[14:12] != 3'd7)) || (i_w_mem_ref);

reg w_ind_addr;
reg w_reg_ref;

reg [11:0] r_addr;
reg        r_we;
reg        r_ce;

reg r_clr_ac;
reg r_clr_e;
reg r_comp_ac;
reg r_load_ac;
reg r_cir_r;
reg r_cir_l;
reg r_inc_ac;

reg r_add;
reg r_load;
reg r_store;
reg r_branch;
reg r_isz;

reg r_clr_reg;
reg r_fetch;
reg r_execute;

// Reset
always @ (negedge reset_n) begin
    if(!reset_n) begin
        w_reg_ref  <= 1'b0;
        w_ind_addr <= 1'b0;
    end
end

// state transition
always @ (posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        c_state <= IDLE;
    end
    else begin
        c_state <= n_state;
    end
end

// computing n_state(next state)
always @ (*) begin
    if(is_fetch) begin
        n_state = FETCH;
    end
    else if(is_decode) begin
        n_state = DECODE;
    end
    else if(is_ind) begin
        n_state = MEM_REF_IND;
    end
    else if(is_mem_ref) begin
        n_state = MEM_REF;
    end
    else if(is_reg_ref) begin
        n_state = REG_REF;
    end
    else if(is_done) begin
        n_state = DONE;
    end
end

// triggering signals
assign is_fetch   = (c_state == DONE) || (c_state == IDLE);
assign is_decode  = (c_state == FETCH) && (!w_ind_addr && !w_reg_ref && !w_mem_ref);
assign is_ind     = (c_state == DECODE) && (w_ind_addr);
assign is_mem_ref = (c_state == MEM_REF_IND) && (w_mem_ref);
assign is_reg_ref = (c_state == DECODE) && (w_reg_ref);
assign is_done    = (c_state == REG_REF) && (i_ex_done);

// internal control signal and output signal by decoding ir[15:0]
always @ (*) begin
    if(ir[15]) begin   // indirect addressing mode, memory-reference
        w_ind_addr = 1'b1;
    end
    else if(!ir[15] && (ir[14:12] != 3'd7)) begin  // direct addresing mode, memory-reference
        case(ir[14:12])
            3'h1 : begin
                r_add  = 1'b1;
                r_we   = 1'b0;
                r_ce   = 1'b1;
                r_addr = ir[11:0];
            end
            3'h2 : begin
                r_load = 1'b1;
                r_we   = 1'b0;
                r_ce   = 1'b1;
                r_addr = ir[11:0];
            end
            3'h3 : begin
                r_store = 1'b1;
                r_we    = 1'b1;
                r_ce    = 1'b1;
                r_addr  = ir[11:0];
            end
            3'h4 : r_branch = 1'b1;
            3'h6 : begin
                r_isz  = 1'b1;
                r_we   = 1'b0;
                r_ce   = 1'b1;
                r_addr = ir[11:0];
            end
        endcase
    end
    else if(!ir[15] && (ir[14:12] == 3'd7)) begin  // register-reference
        w_reg_ref = 1'b1;

        casex(ir[11:0])
            12'h800 : r_clr_ac  = 1'b1;    // Clear AC
            12'h400 : r_clr_e   = 1'b1;    // Clear E
            12'h200 : r_comp_ac = 1'b1;    // Complement AC
            12'h1xx : r_load_ac = 1'b1;    // Load xx to AC
            12'h080 : r_cir_r   = 1'b1;    // Circulate right
            12'h040 : r_cir_l   = 1'b1;    // Circulate left
            12'h020 : r_inc_ac  = 1'b1;    // Increment AC
        endcase
    end
end

// other output logic
always @ (*) begin
    case(c_state)
        IDLE        : r_clr_reg = 1'b1;
        DECODE      : r_fetch   = 1'b0;
        MEM_REF_IND : begin
            r_we   = 1'b0;
            r_ce   = 1'b1;
            r_addr = ir[11:0];
        end
        MEM_REF     : r_execute = 1'b1;
        REG_REF     : r_execute = 1'b1;
    endcase
end

assign o_add     = (w_mem_ref && r_add);
assign o_load    = (w_mem_ref && r_load);
assign o_store   = (w_mem_ref && r_store);
assign o_branch  = (w_mem_ref && r_branch);
assign o_isz     = (w_mem_ref && r_isz);

assign o_clr_ac  = (w_reg_ref && r_clr_ac);
assign o_clr_e   = (w_reg_ref && r_clr_e);
assign o_comp_ac = (w_reg_ref && r_comp_ac);
assign o_load_ac = (w_reg_ref && r_load_ac);
assign o_cir_r   = (w_reg_ref && r_cir_r);
assign o_cir_l   = (w_reg_ref && r_cir_l);
assign o_inc_ac  = (w_reg_ref && r_inc_ac);

assign o_addr    = r_addr;
assign o_we_2    = r_we;
assign o_ce      = r_ce;

assign o_clr_reg = r_clr_reg;
assign o_fetch   = (is_fetch || r_fetch);
assign o_execute = r_execute;
assign o_is_ind  = is_ind;
assign o_is_dir  = is_mem_ref;

endmodule