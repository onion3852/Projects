`timescale 1ns / 1ps

module cpu(clk, reset, data_in, addr, we, data_out);

input clk, reset;
input [15:0] data_in;        // data from sram to cpu
output reg [15:0] data_out;  // data from cpu to sram
output reg [11:0] addr;      // sram's address
output reg we;               // sram control signal (write enable)

reg [15:0] IR,
           DR,
           AC;              
reg [11:0] AR,
           PC;
reg I,          // flip-flop I ( = IR[15] )
    E;          // flip-flop E    
reg [3:0]  SC;  // Sequence Couter(4 bit)

reg [7:0] D;    // opcode's one-hot value
reg [15:0] T;   // SC's one-hot value   


// incrementing SC
// defining Timing signals (one-hot)
always @ (posedge clk) begin            
    SC <= SC + 1;
    #1  case(SC)
            4'd0 :  T <= 16'b0000_0000_0000_0001;  // T[0]
            4'd1 :  T <= 16'b0000_0000_0000_0010;
            4'd2 :  T <= 16'b0000_0000_0000_0100;
            4'd3 :  T <= 16'b0000_0000_0000_1000;
            4'd4 :  T <= 16'b0000_0000_0001_0000;
            4'd5 :  T <= 16'b0000_0000_0010_0000;
            4'd6 :  T <= 16'b0000_0000_0100_0000;
            4'd7 :  T <= 16'b0000_0000_1000_0000;
            4'd8 :  T <= 16'b0000_0001_0000_0000;
            4'd9 :  T <= 16'b0000_0010_0000_0000;
            4'd10 : T <= 16'b0000_0100_0000_0000;
            4'd11 : T <= 16'b0000_1000_0000_0000;
            4'd12 : T <= 16'b0001_0000_0000_0000;
            4'd13 : T <= 16'b0010_0000_0000_0000;
            4'd14 : T <= 16'b0100_0000_0000_0000;
            4'd15 : T <= 16'b1000_0000_0000_0000;  // T[15]
        endcase
end

// Reset
always @ (negedge reset) begin          
    if(!reset) begin
        IR <= 16'b0;
        DR <= 16'b0;
        AC <= 16'b0;
        AR <= 12'b0;
        PC <= 12'b0;
        SC <=  4'b0;
        E  <= 1'b0;
        I  <= 1'b0;
    end
end

// T_0 phase
always @ (posedge clk) begin
    if(T[0])
        AR <= PC;
end

// T_1 phase
always @ (posedge clk) begin
    if(T[1]) begin
        we <= 1'b1;
        addr <= AR;
        #2  
        IR <= data_in;
        PC <= PC + 1;
    end
end

// T_2 phase
always @ (posedge clk) begin
    if(T[2]) begin
        I  <= IR[15];
        AR <= IR[11:0]; 
        
        // decode opcode
        case(IR[14:12])
            3'd0 : D <= 8'b0000_0001;
            3'd1 : D <= 8'b0000_0010;
            3'd2 : D <= 8'b0000_0100;
            3'd3 : D <= 8'b0000_1000;
            3'd4 : D <= 8'b0001_0000;
            3'd5 : D <= 8'b0010_0000;
            3'd6 : D <= 8'b0100_0000;
            3'd7 : D <= 8'b1000_0000;  // D[7] == 1 (register reference instruction)
        endcase
    end
end

// T_3 phase
always @ (posedge clk) begin
    // register reference instruction
    if(D[7] && ~I && T[3]) begin
        casex(IR[11:0])
            12'h800 : AC <= 16'b0;            // Clear AC
            12'h400 : E  <= 1'b0;             // Clear E
            12'h200 : AC <= ~AC;              // Complement AC
            12'h1xx : AC <= IR[7:0];          // Load xx to AC
            12'h080 : begin                             
                       AC <= (AC >> 1);       // Circulate right
                       AC[15] <= E;
                       E <= AC[0];
                       end
            12'h040 : begin                             
                       AC <= (AC << 1);       // Circulate left
                       AC[0] <= E; 
                       E <= AC[15];
                       end
            12'h020 : AC <= AC + 1;           // Increment AC
        endcase
        
        SC <= 4'b0;   // clear SC for next instruction cycle
    end
    
    // memory reference instruction (indirect addressing mode)
    else if(!D[7] && I && T[3]) begin   // AR <= M[AR]
        we <= 1'b1;
        addr <= AR;
        #2
        AR <= data_in;
    end
end

// T_4 phase
always @ (posedge clk) begin
    // memory reference instruction
    if(!D[7] && T[4]) begin
        case(IR[14:12])
            3'h1 : begin     // ADD (DR <= M[AR])
                   we <= 1'b1;
                   addr <= AR;
                   #2
                   DR <= data_in;
                   end
            3'h2 : begin     // LDA (DR <= M[AR])
                   we <= 1'b1;
                   addr <= AR;
                   #2
                   DR <= data_in;
                   end
            3'h3 : begin     // STA (M[AR] <= AC)
                   we <= 1'b0;
                   addr <= AR;
                   data_out <= AC;
                   SC <= 4'b0;
                   end 
            3'h4 : begin     // BUN (PC <= AR)
                   PC <= AR;
                   SC <= 4'b0;
                   end   
            3'h6 : begin     // ISZ (DR <= M[AR])
                   we <= 1'b1;
                   addr <= AR;
                   #2
                   DR <= data_in;
                   end
        endcase
    end
end

// T_5 phase
always @ (posedge clk) begin
    // memory reference instruction
    if(!D[7] && T[5]) begin
        case(IR[14:12])
            3'h1 : begin               // ADD (AC <= AC + DR, E <= Carry_out)
                   {E, AC} <= AC + DR;
                   SC <= 4'b0;
                   end
            3'h2 : begin               // LDA (AC <= DR)
                   AC <= DR;
                   SC <= 4'b0;
                   end
            3'h6 : DR <= DR + 1;       // ISZ (DR <= DR + 1)
        endcase
    end
end

// T_6 phase
always @ (posedge clk) begin
    // memory reference instruction
    if(!D[7] && T[6]) begin
        case(IR[14:12])
            3'h6 : begin     // ISZ (M[AR] <= DR)
                   we <= 1'b0;
                   addr <= AR;
                   data_out <= DR;
                   SC <= 4'b0;
                   
                   if(DR == 16'b0)
                       PC <= PC + 1;
                   end
        endcase
    end
end

endmodule