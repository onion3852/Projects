module sram_controller #(
    parameter addr_width = 4,
    parameter word_depth = 16,
    parameter word_width = 8,
    parameter write_wait = 1,  // wait cycle parameter
    parameter read_wait  = 2   // read cycle parameter
)   (
    input [addr_width-1:0] haddr,
    input [word_width-1:0] hwdata,
    input                  hclk,
    input                  hwrite,
    input [word_width-1:0] sram_dout,

    output [word_width-1:0] hrdata,
    output                  hready,
    output [addr_width-1:0] sram_addr,
    output [word_width-1:0] sram_din,
    output                  sram_clk,
    output                  sram_we
    );
    
    reg [addr_width-1:0] r_addr;
    reg [word_width-1:0] r_wdata;
    reg [word_width-1:0] r_rdata;
    reg                  r_ready;
    reg                  r_we;
    reg                  r_wait;

    always @ (posedge hclk) begin
        r_addr   <= haddr;
        sram_din <= r_wdata;
        sram_we  <= r_we;

    end

    always @ (*) begin
        if(hready)
    end

    always @ (posedge hclk) begin
        if(hwrite) begin
            sram_addr <= r_addr;
            r_wdata   <= hwdata;
            r_ready   <= 1'b0;
            r_we      <= 1'b0;
        end
    end


    /*
    // output
    assign hrdata = r_rdata;
    assign hready = r_ready;
    assign clk    = hclk;
    */

endmodule