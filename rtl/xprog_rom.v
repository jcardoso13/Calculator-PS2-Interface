`timescale 1ns / 1ps
`include "xdefs.vh"
`include "xctrldefs.vh"
`include "xprogdefs.vh"

module xprog_rom(
	    input 			 clk,
	    input [`PROG_ROM_ADDR_W-1:0] pc,
	    output reg [`INSTR_W-1:0] 	 instruction
	    );

   reg [`INSTR_W-1:0] 			  mem [2**`PROG_ROM_ADDR_W-1:0];
   wire 				  en;

   assign en = 1'b1;
 
   // init rom  
   initial begin
      $readmemh("./bootrom.hex",mem,0,2**`PROG_ROM_ADDR_W-1);
   end

   // rom read operation
   always @ (posedge clk) begin
      if (en)
	instruction <= mem[pc];  
   end
   
endmodule
