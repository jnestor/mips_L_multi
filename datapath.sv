//--------------------------------------------------------------------
// datapath.sv - Multicycle MIPS datapath
// David_Harris@hmc.edu 23 October 2005
// Updated to SystemVerilog dmh 12 November 2010
// Refactored into separate files & updated using additional SystemVerilog
// features by John Nestor May 2018
// Key modifications to this module:
//  1. Use enums from new package to make opcode & function codes
//     display symbolic names  during simulation
//--------------------------------------------------------------------



// The datapath unit is a structural verilog module.  That is,
// it is composed of instances of its sub-modules.  For example,
// the instruction register is instantiated as a 32-bit flopenr.
// The other submodules are likewise instantiated.

module datapath(input  logic        clk, reset,
                input logic 	    pcen, irwrite, regwrite,
                input logic 	    alusrca, iord, memtoreg, regdst,
                input logic [1:0]   alusrcb, pcsrc, 
                input logic [2:0]   alucontrol,
		mips_decls_p::opcode_t opcode;
		mips_decls_p::fcode_t funct;		
                output logic 	    zero,
                output logic [31:0] adr, writedata, 
                input logic [31:0]  readdata);


   import mips_decls_p::*;

   // instruction fields
   logic [31:0] 		    instr;
   logic [4:0] 			    rs, rt, rd;  // register fields
   logic [15:0] 		    immed;  // i-type immediate field
   logic [25:0] 		    jmpimmed;  // j-type pseudo-address

  // extract instruction fields from instruction
   assign opcode = opcode_5'(instr[31:26]);
   assign funct = fcode_t'(instr[5:0]);
   assign rs = instr[25:21];
   assign rt = instr[20:16];
   assign rd = instr[15:11];
   assign immed = instr[15:0];
   assign jmpimmed = instr[25:0];
   
   // internal datapath signals

   logic [4:0] 			    writereg;
   logic [31:0] 		    pcnext, pc;
   logic [31:0] 		    instr, data, srca, srcb;
   logic [31:0] 		    a, b;
   logic [31:0] 		    aluresult, aluout;
   logic [31:0] 		    signimm;    // the sign-extended immediate
   logic [31:0] 		    signimmsh;	// the sign-extended immediate shifted left by 2
   logic [31:0] 		    regresult, rd1, rd2;
   logic [31:0] 		    pcjump;     // target address of jump

  // Your datapath hardware goes below.  Instantiate each of the submodules
  // that you need.  Feel free to copy ALU, muxes and other modules from
  // Lab 9.  This directory also includes parameterizable multipliexers
  // mux3.sv (paramaterized 3:1) and mux4.sv (paramterized 4:1)

  // Remember to give your instantiated modules applicable names
  // such as PCREG (PC register), WDMUX (Write Data Mux), etc.
  // so it's easier to understand.

  // ADD CODE HERE

  // datapath

   flopenr #(32) PCR (.clk(clk), .reset(reset), .en(pcen), .d(pcnext), .q(pc));

   mux2 #(32)    ADRMUX (.d0(pc), .d1(aluout), .s(iord), .y(adr));

   flopenr #(32) IREG (.clk(clk), .reset(reset), .en(irwrite), .d(readdata), .q(instr));

   flopr #(32)   MDREG (.clk(clk), .reset(reset), d(readdata), .q(data));

   mux2 #(5)     WRMUX (.d0(rt), .d1(rd), .s(regdst), .y(writereg));

   mux2 #(32)    RESMUX (.d0(aluout), .d1(data), .s(memtoreg), .y(regresult));

   regfile       RF (.clk(clk), .we3(regwrite), .ra1(rs), .ra2(rt),
		     .wa3(writereg), .wd3(regresult), .rd1(rd1), .rd2(rd2));

   flopr         AREG (.clk(clk), .reset(reset), .d(rd1), .q(a));

   flopr         BREG (.clk(clk), .reset(reset), .d(rd2), .q(b));

   signext       SE (.a(immed), .y(signimm));

   sl2           IMMSH (.a(signimm), .y(signimmsh));

   assign pcjump = {pc[31:28], jmpimmed, 2'b00};  // maybe add a module to do this?
   
   mux2          SRCAMUX (.d0(pc), .d1(a), .s(alusrca), .y(srca));

   mux4          SRCBMUX (.d0(b), .d1(32'h4), .d2(signimm), .d3(signimmsh),
			  .s(alusrcb), .y(srcb));

   alu           ALU (.a(srca), .b(srcb), .f(alucontrol), .y(aluresult));
   
   flopr         ALUREG (.clk(clk), .reset(reset), .d(aluresult), .y(aluout));

   mux3          PCMUX (.d0(aluresult), .d1(aluout), .d3(pcjump), .s(pcsrc), .y(pcnext));
  
endmodule
