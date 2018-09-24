`timescale 1ns / 1ps
`include "xdefs.vh"
`include "xctrldefs.vh"
`include "xprogdefs.vh"

module xprog (
	      input 			clk,
	      input 			rst,

	      // data interface
	      input 			data_sel,
	      input 			data_we,
	      input [`PROG_ADDR_W-1:0] 	data_addr,
	      input [`DATA_W-1:0] 	data_in,
	      output [`DATA_W-1:0] 	data_out,
					
`ifdef DMA_USE
	      //dma interface 
	      input 			dma_sel,
	      input 			dma_we,
	      input [`PROG_ADDR_W-1:0] 	dma_addr,
	      input [`DATA_W-1:0] 	dma_data_in,
	      output [`DATA_W-1:0] 	dma_data_out
`endif

	      // instruction interface 
	      input [`PROG_ADDR_W-1:0] 	pc,
	      output reg [`INSTR_W-1:0] instruction
	      );
   
   // PROG ROM DATA
   wire [`INSTR_W-1:0] 			   data_from_rom;

   // PROG RAM DATA
   wire [`INSTR_W-1:0] 			   data_from_ram;

`ifdef DMA_USE
   wire 				   dma_we_int;
   assign dma_we_int = dma_sel & dma_we;
`endif

   reg [`PROG_ADDR_W-1:0] 		   pc_reg;
   
   
   // INSTRUCTION ADDRESS DECODER
   always @ * begin
      if ( (pc_reg & ({`PROG_ADDR_W{1'b1}}<<`PROG_ROM_ADDR_W) ) == `PROG_ROM ) begin
	 instruction = data_from_rom;
      end
      else if ( (pc_reg & ({`PROG_ADDR_W{1'b1}} << `PROG_RAM_ADDR_W)) == `PROG_RAM ) 
	instruction = data_from_ram;
      else
	$display("Warning: invalid prog address %d at time %d ns", pc, $time);
   end
   
   //PROG ROM
   xprog_rom rom(
		 .clk(clk),
		 .pc(pc[`PROG_ROM_ADDR_W-1:0]),
		 .instruction(data_from_rom)
		 );

   //PROG RAM
   xprog_ram ram(
		 //instruction interface
		 .pc(pc[`PROG_RAM_ADDR_W-1:0]),
		 .instruction(data_from_ram),
		 
		 //data interface
		 .data_sel(data_sel),
		 .data_we(data_we),
		 .data_addr(data_addr[`PROG_RAM_ADDR_W-1:0]),
		 .data_in(data_in),
		 .data_out(data_out),
		 
`ifdef DMA_USE
		 .dma_addr(dma_addr),
		 .dma_data_in(dma_data_in),
		 .dma_data_out(dma_data_out)
`endif
		 .clk(clk),
		 .rst(rst)
		 );


   // PC register
   always @(posedge clk)
     if(rst)
       pc_reg <= `PROG_ADDR_W'h0;
     else
       pc_reg <= pc;
     
endmodule
