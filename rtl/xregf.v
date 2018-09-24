`timescale 1ns / 1ps
`include "xdefs.vh"
`include "xregfdefs.vh"

module xregf (
	      input 		       clk,

	      //host interface 
	      input 		       ext_we,
	      input [`REGF_ADDR_W-1:0] ext_addr,
	      input [`DATA_W-1:0]      ext_data_in,
	      output [`DATA_W-1:0]     ext_data_out,

	      //versat interface 
	      input 		       int_sel,
	      input 		       int_we,
	      input [`REGF_ADDR_W-1:0] int_addr,
	      input [`DATA_W-1:0]      int_data_in,
	      output [`DATA_W-1:0]     int_data_out
	      );


   // Implementation as 2-port distributed RAM needs two reg files
   reg [`DATA_W-1:0] 				reg_1 [2**`REGF_ADDR_W-1:0];
   reg [`DATA_W-1:0] 				reg_2 [2**`REGF_ADDR_W-1:0];

   wire 					int_we_int;
   wire [`DATA_W-1:0] 				data_in;
   wire [`REGF_ADDR_W-1:0] 			addr;
   wire 					we;

   assign int_we_int = int_sel & int_we;
   assign we = ext_we | int_we_int;
   assign addr = (ext_we == 1'b1) ? ext_addr : int_addr;
   assign data_in = (ext_we == 1'b1) ? ext_data_in : int_data_in;

   assign ext_data_out = reg_1[ext_addr];
   assign int_data_out = reg_2[int_addr];

   always @ (posedge clk) begin
      if (we) begin
	 reg_1[addr] <= data_in;
	 reg_2[addr] <= data_in;
      end
   end

endmodule
