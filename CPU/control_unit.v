`timescale 1ns / 1ps

module control_unit(
    input        clk,
    input        reset_n,
    input        i_run,
    input        i_ex_done,
    input [15:0] ir,

    output       o_read,
    output       o_write,

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
    output       o_execute
    );

//parameter DWIDTH 16;
//parameter ADDR_WIDTH 12;

// state for FSM
localparam IDLE        = 3'b0;
localparam FETCH       = 3'b1;
localparam REG_REF     = 3'b2;
localparam MEM_REF_IND = 3'b3;  // indirect addressing
localparam MEM_REF     = 3'b4;
localparam WRITE       = 3'b5;
localparam DONE        = 3'b6;
reg [2:0] c_state;
reg [2:0] n_state;

wire is_ind;      // triggering MEM_REF_IND
wire is_mem_ref;  // triggering MEM_REF
wire is_reg_ref;  // triggering REG_REF
wire is_write;    // triggering WRITE
wire is_done;     // triggering DONE
wire is_fetch;    // triggering FETCH

reg r_read;
reg r_write;

reg w_reg_ref;
reg r_clr_ac;
reg r_clr_e;
reg r_comp_ac;
reg r_load_ac;
reg r_cir_r;
reg r_cir_l;
reg r_inc_ac;

reg w_mem_ref;
reg w_ind_addr;
reg r_add;
reg r_load;
reg r_store;
reg r_branch;
reg r_isz;

reg r_clr_reg;
reg r_fetch;
reg r_execute;


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
    else if(is_ind) begin
        n_state = MEM_REF_IND;
    end
    else if(is_mem_ref) begin
        n_state = MEM_REF;
    end
    else if(is_write) begin
        n_state = WRITE;
    end
    else if(is_reg_ref) begin
        n_state = REG_REF;
    end
    else if(is_done) begin
        n_state = DONE;
    end
    else begin
        n_state = IDLE;
    end
end

// triggering signals
assign is_fetch   = (c_state == DONE);
assign is_ind     = (c_state == FETCH) && (w_ind_addr);
assign is_mem_ref = (c_state == MEM_REF_IND) && (w_mem_ref);
assign is_write   = (c_state == MEM_REF) && (w_mem_ref);
assign is_reg_ref = (c_state == FETCH) && (w_reg_ref);
assign is_done    = ( (c_state == REG_REF) && (i_ex_done) ) ||
                    ( (c_state == WRITE)   && (i_ex_done) );

// internal control signal by decoding ir[15:0]
always @ (*) begin
    if(ir[15]) begin   // indirect addressing mode, memory-reference
        w_ind_addr <= 1'b1;
    end
    else if(!ir[15] && (ir[14:12] != 3'd7)) begin  // direct addresing mode, memory-reference
        w_mem_ref <= 1'b1;

        case(ir[14:12])
            3'h1 : r_add    <= 1'b1;
            3'h2 : r_load   <= 1'b1;
            3'h3 : r_store  <= 1'b1;
            3'h4 : r_branch <= 1'b1;
            3'h6 : r_isz    <= 1'b1;
        endcase
    end
    else if(!ir[15] && (ir[14:12] == 3'd7)) begin  // register-reference
        w_reg_ref <= 1'b1;

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

// output logic
always @ (*) begin
    case(c_state)
        IDLE        : r_clr_reg = 1'b1;
        FETCH       : r_fetch  = 1'b1;
        MEM_REF_IND : begin
                      r_read    = 1'b1;
                      r_execute = 1'b1;
                      end
        MEM_REF     : begin
                      r_read    = 1'b1;
                      r_execute = 1'b1;
                      end
        WRITE       : r_write   = 1'b1;
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

assign o_read    = r_read;
assign o_write   = r_write;

assign o_clr_reg  = r_clr_reg;
assign o_fetch    = r_fetch;
assign o_execute  = r_execute;

endmodule


// execute 완료 시 어떤 signal trigger하여 is_done 만들 수 있게 하자
// datapath에서 r_ex_done 정의하고 assign o_ex_done = r_ex_done 하고
// o_ex_done signal을 control_unit의 i_ex_done으로 연결된다고 하자

// r_read에 의한 o_read는 mem에 read로 접근하기 위한 output으로 하자
// r_write에 의한 o_write는 mem에 write로 접근하기 위한 output

// r_execute는 EXECUTE stage를 실행하기위한 trigger로 사용

// non pipeline상태임을 기억하고 작성하자