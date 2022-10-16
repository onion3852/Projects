`timescale 1ns/1ps

module sram_controller #(
    parameter ADDR_WIDTH = 4,
    parameter WORD_DEPTH = 16,
    parameter WORD_WIDTH = 8,
    parameter WRITE_WAIT = 1,  // wait cycle parameter
    parameter READ_WAIT  = 2   // read cycle parameter
)   (
    input [ADDR_WIDTH-1:0] haddr,
    input [WORD_WIDTH-1:0] hwdata,
    input                  hclk,
    input                  hwrite,
    input [WORD_WIDTH-1:0] sram_dout,

    output [WORD_WIDTH-1:0] hrdata,
    output                  hready,
    output [ADDR_WIDTH-1:0] sram_addr,
    output [WORD_WIDTH-1:0] sram_din,
    output                  sram_clk,
    output                  sram_we
    );
    
    reg [ADDR_WIDTH-1:0] r_addr;
    reg [WORD_WIDTH-1:0] r_wdata;
    reg [WORD_WIDTH-1:0] r_rdata;
    reg                  r_ready;
    reg                  r_we;

    reg [1:0] r_wait;  // counting wait cycle
    reg       r_wr;    // write : high, read : low
    reg       r_next_phase;


    always @ (posedge hclk) begin
        r_rdata <= sram_dout;
        r_addr  <= haddr;

        // counting wait cycle &
        // write data control
        if(r_ready) begin
            r_next_phase <= 1'b1;
            r_wait       <= 1'b0;
            r_we         <= 1'b1;  // write enable high (no write)
        end
        else if(!r_ready) begin
            r_wait <= r_wait + 1;
            r_wr <= r_wr;

            if(r_wr) begin
                r_wdata <= hwdata;
            end
        end
    end

    always @ (negedge r_ready) begin
        if(hwrite) begin
            r_wr <= 1'b1;
        end
        else if(!hwrite) begin
            r_wr <= 1'b0;
        end
    end
    
    // address phase
    always @ (posedge hclk) begin
        if(r_ready && r_next_phase) begin
            r_ready      <= 1'b0;
            r_next_phase <= 1'b0;
        end
    end

    // hready signal generating
    always @ (*) begin
        if((r_wr) && (r_wait == WRITE_WAIT)) begin
            r_we    = 1'b0;
            r_ready = 1'b1;
            r_wait  = 1'b0;
        end
        else if((!r_wr) && (r_wait == READ_WAIT)) begin
            r_we    = 1'b1;
            r_ready = 1'b1;
            r_wait  = 1'b0;
        end
    end

    // output
    assign hrdata    = r_rdata;
    assign hready    = r_ready;
    assign sram_din  = r_wdata;
    assign sram_addr = r_addr;
    assign sram_clk  = hclk;
    assign sram_we   = r_we;

endmodule