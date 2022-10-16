`timescale 1ns/1ps

module tb_sram_controller#(
    parameter ADDR_WIDTH = 4,
    parameter WORD_DEPTH = 16,
    parameter WORD_WIDTH = 8
    );

// AHB signal
reg [ADDR_WIDTH-1:0]  HADDR;
reg [WORD_WIDTH-1:0]  HWDATA;
reg                   HWRITE;
reg                   HCLK;
wire [WORD_WIDTH-1:0] HRDATA;
wire                  HREADY;

// Local signal
wire [ADDR_WIDTH-1:0] SRAM_ADDR;
wire [WORD_WIDTH-1:0] SRAM_DOUT;
wire [WORD_WIDTH-1:0] SRAM_DIN;
wire                  SRAM_CLK;
wire                  SRAM_WE;

integer file_pointer;
integer i, num;
reg [12:0] test_vector [13:0];

// sram_controller instantiation
sram_controller slave (
    .haddr    (HADDR),
    .hwdata   (HWDATA),
    .hclk     (HCLK),
    .hwrite   (HWRITE),
    .sram_dout(SRAM_DOUT),

    .hrdata   (HRDATA),
    .hready   (HREADY),
    .sram_addr(SRAM_ADDR),
    .sram_din (SRAM_DIN),
    .sram_clk (SRAM_CLK),
    .sram_we  (SRAM_WE)
    );

// sram instantiation
sram_16x8 sram (
    .addr(SRAM_ADDR),
    .din (SRAM_DIN),
    .dout(SRAM_DOUT),
    .clk (SRAM_CLK),
    .we  (SRAM_WE)
    );

always #5 HCLK = ~HCLK;

always @ (posedge HCLK) begin
    #1 {HWRITE, HADDR, HWDATA} <= test_vector[num];
    #1 num = num + 1;
end

initial begin
    $readmemb("in.txt", test_vector);
    file_pointer = $fopen("out.txt");

    HCLK = 1'b0;  num  = 0;
    tb_sram_controller.slave.r_ready = 1;  // initial hready setting

    #160
    for (i = 0; i < 2; i = i + 1) begin
        $fdisplay(file_pointer, "%b", tb_sram_controller.sram.mem[i]);
    end

    $fclose("out.txt");
    $finish;
end

endmodule
