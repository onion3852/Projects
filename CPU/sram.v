`timescale 1ns / 1ps

module sram #(
    parameter ADDR_WIDTH = 12,
    parameter WORD_DEPTH = 4096,
    parameter WORD_WIDTH = 16
)   (
    input                  clk,
    input [WORD_WIDTH-1:0] i_data, 
    input [ADDR_WIDTH-1:0] i_addr, 
    input                  i_we,   // write_enable
    input                  i_ce,   // chip_enable

    output [WORD_WIDTH-1:0] o_data
    );

reg o_data;
reg [WORD_WIDTH1:0] r_data;
reg [WORD_WIDTH-1:0] mem[0:WORD_DEPTH-1];    // 2^12 X 16 sram

always @ (posedge clk) begin
    if(i_ce && i_we) begin        // write
        mem[i_addr] <= i_data[WORD_WIDTH-1:0];
    end
    else if(i_ce && !i_we) begin  // read
        r_data <= mem[i_addr];
    end
end

assign o_data = (i_ce & !i_we) ? r_data : 'hz;

endmodule