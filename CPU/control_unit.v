`timescale 1ns / 1ps

module control_unit(
    input        clk,
    input        reset_n,
    input [15:0] ir,

    output       o_read,
    output       o_write,
    output       o_we,

    output       o_reg_ref,
    output       o_clr_sc,
    output       o_clr_ac,
    output       o_clr_e,
    output       o_comp_ac,
    output       o_load_ac,
    output       o_cir_r,
    output       o_cir_l,
    output       o_inc_ac,

    output       o_mem_ref,
    output       o_ind_addr,
    output       o_add,
    output       o_load,
    output       o_store,
    output       o_branch,
    output       o_isz,

    output       o_is_idle
    );

parameter IDLE    0;
parameter READ    1;
parameter WRITE   2;
parameter BRANCH  3;
parameter REG_REF 4;
parameter MEM_REF 5;

reg r_read;
reg r_write;
reg r_we;

reg r_reg_ref;
reg r_clr_sc;
reg r_clr_ac;
reg r_clr_e;
reg r_comp_ac;
reg r_load_ac;
reg r_cir_r;
reg r_cir_l;
reg r_inc_ac;

reg r_mem_ref;
reg r_ind_addr;
reg r_add;
reg r_load;
reg r_store;
reg r_branch;
reg r_isz;

reg r_is_idle;



// making control signal using ir signal
always @ (posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        r_is_idle <= 1'b1;   // clear Registers
    end
    else if(ir[15]) begin   // indirect addressing mode 
                            // memory-reference
        r_mem_ref  <= 1'b1;
        r_ind_addr <= 1'b1;
        r_read     <= 1'b1;
    end
    else if(!ir[15] && (ir[14:12] != 3'd7)) begin  // direct addresing mode
                                                   // memory-reference
        r_mem_ref <= 1'b1;
        r_read    <= 1'b1;

        case(ir[14:12])
            3'h1 : r_add    <= 1'b1;
            3'h2 : r_load   <= 1'b1;
            3'h3 : r_store  <= 1'b1;
            3'h4 : r_branch <= 1'b1;
            3'h6 : r_isz    <= 1'b1;
        endcase
    end
    else if(!ir[15] && (ir[14:12] == 3'd7)) begin  // register-reference
        r_reg_ref <= 1'b1;
        r_clr_sc  <= 1'b1;

        casex(ir[11:0])
            12'h800 : r_clr_ac  <= 1'b1;    // Clear AC
            12'h400 : r_clr_e   <= 1'b1;    // Clear E
            12'h200 : r_comp_ac <= 1'b1;    // Complement AC
            12'h1xx : r_load_ac <= 1'b1;    // Load xx to AC
            12'h080 : r_cir_r   <= 1'b1;    // Circulate right
            12'h040 : r_cir_l   <= 1'b1;    // Circulate left
            12'h020 : r_inc_ac  <= 1'b1;    // Increment AC
        endcase
    end
end

assign o_read    = r_read;
assign o_write   = r_write;
assign o_we      = r_we;

assign o_reg_ref = r_reg_ref;
assign o_clr_sc  = r_clr_sc;
assign o_clr_e   = r_clr_e;
assign o_comp_ac = r_comp_ac;
assign o_load_ac = r_load_ac;
assign o_cir_r   = r_cir_r;
assign o_cir_l   = r_cir_l;
assign o_inc_ac  = r_inc_ac;

assign o_mem_ref  = r_mem_ref;
assign o_ind_addr = r_ind_addr;
assign o_add      = r_add;
assign o_load     = r_load;
assign o_store    = r_store;
assign o_branch   = r_branch;
assign o_isz      = r_isz;

assign o_is_idle = r_is_idle;

endmodule


// non pipeline상태임을 기억하고 작성하자