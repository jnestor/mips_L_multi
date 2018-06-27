//-------------------------------------------------------
// maindec.sv - Multicyle MIPS contoroller FSM
// David_Harris@hmc.edu 8 November 2005
// Update to SystemVerilog 17 Nov 2010 DMH
// Refactord and updated by John Nestor
// Key changes to this module:
//  1. replace state code parameters with enum
//     (simulator will display symboic state names)
//  2. import opcodes from mips_decls_p package
//  3. set control signals individually in state machine
//     instead of as a bitvector (easier to understand
//     and follows state diagram in Fig. 7.42)
//------------------------------------------------

module maindec(input  logic       clk, reset, 
               input  mips_decls_p::opcode_t  opcode, 
               output logic       pcwrite, memwrite, irwrite, regwrite,
               output logic       alusrca, branch, iord, memtoreg, regdst,
               output logic [1:0] alusrcb, pcsrc,
               output logic [1:0] aluop);

   import mips_decls_p::*;
   
   enum logic [3:0} {
     FETCH   = 4'd0,
     DECODE  = 4'd1,
     MEMADR  = 4'd2,
     MEMRD   = 4'd3,
     MEMWB   = 4'd4,
     MEMWR   = 4'd5,
     RTYPEEX = 4'd6,
     RTYPEWB = 4'd7,
     BEQEX   = 4'd8,
     ADDIEX  = 4'd9,
     ADDIWB  = 4'd10,
     JEX     = 4'd11
  } state, nextstate;

  // state register
  always_ff @(posedge clk or posedge reset)			
    if(reset) state = FETCH;
    else state = nextstate;

  // ADD CODE HERE
  // Finish entering the next state logic below.  We've completed the first 
  // two states, FETCH and DECODE, for you.  See Figure 7.42 in the book.

  // next state logic
  always_comb
    case(state)
      FETCH:   nextstate = DECODE;
      DECODE:  case(op)
                 OP_LW:      nextstate = MEMADR;
                 OP_SW:      nextstate = MEMADR;
                 OP_RTYPE:   nextstate = RTYPEEX;
                 OP_BEQ:     nextstate = BEQEX;
                 OP_ADDI:    nextstate = ADDIEX;
                 OP_J:       nextstate = JEX;
                 default: nextstate = 4'bx; // should never happen
               endcase
      // Add code here
      MEMADR:
      MEMRD: 
      MEMWB: 
      MEMWR: 
      RTYPEEX: 
      RTYPEWB: 
      BEQEX:   
      ADDIEX:  
      ADDIWB:  
      JEX:     
      default: nextstate = 4'bx; // should never happen
    endcase

  // output logic

  // ADD CODE HERE
  // Finish entering the output logic below.  We've entered the
  // output logic for the first two states, FETCH(S0) and DECODE(S1), for you.
  always_comb
    begin
       // default output values
       pcwrite = 0;
       memwrite = 0;
       irwrite = 0;
       regwrite = 0;
       alusrca = 0;
       branch = 0;
       iord = 0;
       memtoreg = 0;
       regdst = 0;
       alusrcb = 2'b00;
       pcsrc = 2'b00;
       aluop = 2'b00;
       case(state)
	 FETCH:
	   begin
	      iord = 0;
	      alusrca = 0;
	      alusrcb = 2'b01;
	      aluop = 2'b00;
	      pcsrc = 2'b00;
	      irwrite = 1;
	      pcwrite = 1;
	   end
	 DECODE:
	   begin
	      alusrca = 0;
	      alusrcb = 2'b11;
	      aluop = 2'b00;
	   end
	 
	 // add code here to specify outputs for remaining states
	 // note you only need to add values specified in each state bubble
	 // because default values are set before the case statement
    
	 default: // should never happen - make outputs x to show error in simulator waveform
	   begin
	      pcwrite = 1'bx;
	      memwrite = 1'bx;
	      irwrite = 1'bx;
	      regwrite = 1'bx;
	      alusrca = 1'bx;
	      branch = 1'bx;
	      iord = 1'bx;
	      memtoreg = 1'bx;
	      regdst = 1'bx;
	      alusrcb = 2'bxx;
	      pcsrc = 2'bxx;
	      aluop = 2'bxx;
	   end
       endcase // case (state)
    end
endmodule
