`timescale 1ns / 1ps

module CPU #(
    parameter DWIDTH 16,
    parameter ADDR_WIDTH 12
)   (
    input clk,
    input reset_n
    );

wire [DWIDTH-1:0]     ir;
wire [DWIDTH-1:0]     data_r;
wire [DWIDTH-1:0]     data_w;
wire [ADDR_WIDTH-1:0] addr;
wire we;

wire clr_ac;
wire clr_e;
wire comp_ac;
wire load_ac;
wire cir_r;
wire cir_l;
wire inc_ac;

wire add;
wire load;
wire store;
wire branch;
wire isz;
wire clr_reg;
wire fetch;
wire execute;
wire is_ind;
wire is_dir;

wire ex_done;
wire mem_ref;


// instantiation
datapath DATAPATH (
    .clk      (clk),
    .i_data   (data_r),
    .i_clr_ac (clr_ac),
    .i_clr_e  (clr_e),
    .i_comp_ac(comp_ac),
    .i_load_ac(load_ac),
    .i_cir_r  (cir_r),
    .i_cir_l  (cir_l),
    .i_inc_ac (inc_ac),

    .i_add    (add),
    .i_load   (load),
    .i_store  (store),
    .i_branch (branch),
    .i_isz    (isz),
    .i_clr_reg(clr_reg),
    .i_fetch  (fetch),
    .i_execute(execute),
    .i_is_ind (is_ind),
    .i_is_dir (is_dir),

    .o_data     (data_w),
    .o_addr     (addr),
    .o_we       (we),
    .o_ex_done  (ex_done),
    .o_w_mem_ref(mem_ref)
    );

control_unit CONTROL (
    .clk        (clk),
    .reset_n    (reset_n),
    .i_w_mem_ref(mem_ref),
    .i_ex_done  (ex_done),
    .ir         (ir),

    .o_addr   (addr),
    .o_we     (we),

    .o_clr_ac (clr_ac),
    .o_clr_e  (clr_e),
    .o_comp_ac(comp_ac),
    .o_load_ac(load_ac),
    .o_cir_r  (cir_r),
    .o_cir_l  (cir_l),
    .o_inc_ac (inc_ac),

    .o_add    (add),
    .o_load   (load),
    .o_store  (store),
    .o_branch (branch),
    .o_isz    (isz),
    .o_clr_reg(clr_reg),
    .o_fetch  (fetch),
    .o_execute(execute),
    .o_is_ind (is_ind),
    .o_is_dir (is_dir)
    );


endmodule