module sram_16x8 #(
    parameter addr_width = 4,
    parameter word_depth = 16,
    parameter word_width = 8
)   (
    input [addr_width-1:0] addr,
    input [word_width-1:0] din,
    input                  clk,
    input                  we,

    output [word_width-1:0] dout
    );

reg [word_width-1:0] mem [0:word_depth-1];
reg [word_width-1:0] dout;

always @ (posedge clk) begin
    if(!we) begin
        mem[addr] <= din[word_width-1:0];
    end
end

always @ (posedge clk) begin
    if(we) begin
        #1
        dout <= mem[addr];
    end
end
    
endmodule