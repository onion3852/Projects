`timescale 1ns / 1ps

module datapath (
    input clk,

    input o_read,
    input o_write,
    input o_we,

    input o_reg_ref,
    input o_clr_sc,
    input o_clr_ac,
    input o_clr_e,
    input o_comp_ac,
    input o_load_ac,
    input o_cir_r,
    input o_cir_l,
    input o_inc_ac,

    input o_mem_ref,
    input o_ind_addr,
    input o_add,
    input o_load,
    input o_store,
    input o_branch,
    input o_isz,

    input o_is_idle
    );
    
// Core
always @ (posedge clk) begin
    if(o_reg_ref && o_clr_sc) begin
        
    end
end






endmodule