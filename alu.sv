//--------------------------------------------------------------
// alu.sv - functional model of MIPS ALU for simulation purposes
// Remove this file for ECE 212 MIPS Labs
// John Nestor nestorj@lafayette.edu May 2018
// Added to refactored MIPS Single Cycle design
//--------------------------------------------------------------

module alu(
    input logic [31:0] a, b,
    input logic [2:0] f,
    output logic [31:0] y,
    output logic zero
    );

  always_comb
  begin
    case (f)
      3'b000 : result = a & b; 
      3'b001 : result = a | b; 
      3'b010 : result = a + b; 
      3'b100 : result = a & ~b;
      3'b101 : result = a | ~b;
      3'b110 : result = a - b; // SUBTRACT
      3'b111 : if (a < b) result = 32'd1; 
               else result = 32'd0; //SLT      
      default : result = 'x;
   endcase
   if (result == 32'd0) zero = 1;
   else zero = 0;
 end    
    
endmodule
