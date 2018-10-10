`timescale 1ns / 1ps

`include "xdefs.vh"
`include "xctrldefs.vh"
`include "xprogdefs.vh"
`include "xregfdefs.vh"


module xtop (
	     //INSERT EXTERNAL INTERFACES HERE
	     // parallel interface
	     input [`REGF_ADDR_W-1:0] par_addr,
	     input 		      par_we,
	     input [`DATA_W-1:0]      par_in,
	     output [`DATA_W-1:0]     par_out,
		  output [7:0] 	gpo_data_out,

	     //MANDATORY INTERFACE SIGNALS
	     input 		      clk,
	     input 		      rst
	     );

   //
   //
   // CONNECTION WIRES
   //
   //
   
   // PROGRAM MEMORY/CONTROLLER INTERFACE
   wire [`INSTR_W-1:0] 		  instruction;
   wire 			  instr_valid;
   wire [`PROG_ADDR_W-1:0] 	  pc;

   // DATA BUS
   wire 			  data_sel;
   wire 			  data_we;
   wire [`ADDR_W-1:0] 		  data_addr;
   reg [`DATA_W-1:0] 		  data_to_rd;
   wire [`DATA_W-1:0] 		  data_to_wr;

   // MODULE SELECTION SIGNALS
   reg 				  prog_sel;
   wire [`DATA_W-1:0] 		  prog_data_to_rd;
   
   reg 				  regf_sel;
   wire [`DATA_W-1:0] 		  regf_data_to_rd;
   
   reg 				  cprt_sel;
 
	reg 					gpo_sel;
   
   
   
   //
   //
   // FIXED SUBMODULES
   //
   //
   
   //
   // CONTROLLER MODULE
   //
   xctrl controller (
		     .clk(clk), 
		     .rst(rst),
		     
		     // Program memory interface
		     .pc(pc),
		     .instruction(instruction),
		     
		     // Internal data bus
		     .data_sel(data_sel),
		     .data_we (data_we), 
		     .data_addr(data_addr),
		     .data_to_rd(data_to_rd), 
		     .data_to_wr(data_to_wr)
		     );
		     
	xgpo gpo(
			.clk(clk),
			.rst(rst),
			.data_in(data_to_wr[7:0]),
			.data_out(gpo_data_out),
			.sel(gpo_sel)
			);

   // PROGRAM MEMORY MODULE
   xprog prog (
	       .clk(clk),
	       .rst(rst),

	       //data interface 
	       .data_sel(prog_sel),
	       .data_we(data_we),
	       .data_addr(data_addr[`PROG_ADDR_W-1:0]),
	       .data_in(data_to_wr),
	       .data_out(prog_data_to_rd),

	       //DMA interface 
`ifdef DMA_USE
	       .dma_req(dma_prog_req),	       
	       .dma_rnw(dma_rnw),
	       .dma_addr(dma_addr[`PROG_ADDR_W-1:0]),
	       .dma_data_in(dma_data_from),
	       .dma_data_out(dma_data_from_prog),
`endif	       

	       // instruction interface
	       .pc(pc),
       	   .instruction(instruction)      
	       );

   // ADDRESS DECODER
   always @ * begin
      prog_sel = 1'b0;
      regf_sel = 1'b0;
      cprt_sel = 1'b0;
      gpo_sel  =1'b0;

      if (`REGF_BASE == (data_addr & ({`ADDR_W{1'b1}}<<`REGF_ADDR_W))) begin
	 regf_sel = 1'b1;
         data_to_rd = regf_data_to_rd;
      end else if (`CPRT_BASE == data_addr) begin
	 cprt_sel = 1'b1;
      end else if (`PROG_BASE == (data_addr & ({`ADDR_W{1'b1}}<<`PROG_ADDR_W))) begin
         prog_sel = 1'b1;
         data_to_rd = prog_data_to_rd;
      end else if (`GPO_BASE == data_addr) begin
		gpo_sel	=	1'b1;
      end else if(data_sel === 1'b1)
	 $display("Warning: unmapped controller issued data address %x at time %f", data_addr, $time);
   end // always @ *

   //
   //
   // USER MODULES INSERTED BELOW
   //
   //
   
   // HOST-CONTROLLER SHARED REGISTER FILE
   xregf regf (
	       .clk(clk),
	       
	       //host interface (external)
	       .ext_we(par_we),
	       .ext_addr(par_addr),
	       .ext_data_in(par_in),
	       .ext_data_out(par_out),
			
	       //versat interface (internal)
	       .int_sel(regf_sel),
	       .int_we(data_we),
	       .int_addr(data_addr[`REGF_ADDR_W-1:0]),
	       .int_data_in(data_to_wr),
	       .int_data_out(regf_data_to_rd)
	       );

   xcprint cprint (
		   .clk(clk),
		   .sel(cprt_sel),
		   .data_in(data_to_wr[7:0])
		   );
   

   
endmodule
