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


    always @ (posedge hclk) begin
        r_addr  <= haddr;
        r_rdata <= sram_dout;
        sram_we <= r_we;
        hready  <= r_ready;

        // counting wait cycle &
        // write data control
        if(r_ready) begin
            r_wait <= 1'b0;
            r_we   <= 1'b1;  // write enable high
        end
        else if(!r_ready) begin
            r_wait  <= r_wait + 1;

            if(r_wr) begin
                r_wdata <= hwdata;
            end
        end
    end

    // hready signal generating
    always @ (*) begin
        if((r_wait == WRITE_WAIT) && (r_wr)) begin
            r_we    <= 1'b0;
            #2
            r_ready <= 1'b1;
            r_wait  <= 1'b0;
        end
        else if((r_wait == READ_WAIT) && (!r_wr)) begin
            r_we    <= 1'b1;
            #2
            r_ready <= 1'b1;
            r_wait  <= 1'b0;
        end
    end

    always @ (posedge hclk) begin
        if(hwrite) begin
            sram_addr <= r_addr;
            r_ready   <= 1'b0;
            r_wr      <= 1'b1;  // write
        end
        else if(!hwrite) begin
            sram_addr <= r_addr;
            r_ready   <= 1'b0;
            r_wr      <= 1'b0;  // read
        end
    end

    // output
    assign sram_din = r_wdata;
    assign hrdata   = r_rdata;
    assign sram_clk = hclk;

endmodule