`timescale 1ns / 1ps
`include "xdefs.vh"
`include "xprogdefs.vh"
`include "xctrldefs.vh"

module xprog_ram (
		 // instruction interface
		 input [`PROG_RAM_ADDR_W-1:0] pc,
		 output reg [`INSTR_W-1:0]    instruction,
	
		 //data interface 
		 input 			      data_sel,
		 input 			      data_we,
		 input [`PROG_RAM_ADDR_W-1:0] data_addr,
		 input [`DATA_W-1:0] 	      data_in,
		 output [`DATA_W-1:0] 	      data_out,
					    
`ifdef DMA_USE
		 // DMA interface
		 input 			      dma_sel,
		 input 			      dma_we,
		 input [`PROG_ADDR_W-1:0]     dma_addr,
		 input [`DATA_W-1:0] 	      dma_data_in,
		 output [`DATA_W-1:0] 	      dma_data_out
`endif
		 input 			      clk
		 );

   //
   // the memory
   //
   reg [`INSTR_W-1:0] 			    mem [2**`PROG_RAM_ADDR_W-1:0];

   // instruction port enable
   wire 				    instr_en;
   
   // memory data port input 
   wire [`DATA_W-1:0] 			    data_in_int;

   // memory data port output
   reg [`DATA_W-1:0] 			    data_out_int;

   // memory data port address
   wire [`PROG_RAM_ADDR_W-1:0] 		    data_addr_int;

   // memory enable
   wire 				    data_en_int;
   
   // memory write enable
   wire 				    data_we_int;
   
   
   //enable instruction port
   assign instr_en = 1'b1;

   //assign shared (between controller and DMA) memory data port signals
`ifdef DMA_USE
   assign data_addr_int = (data_sel)? data_addr : dma_addr;
   assign data_we_int = (data_sel)? data_we : dma_we;
   assign data_in_int = (data_sel)? data_in : dma_data_in;
   assign dma_data_out = data_out_int;
   assign data_en_int = (data_sel)? data_sel : dma_sel;
`else
   assign data_addr_int = data_addr;
   assign data_we_int = data_we;
   assign data_in_int = data_in;
   assign data_en_int = data_sel;
`endif
   assign data_out = data_out_int;
   
   // init RAM
   initial begin
      $readmemh("./program.hex",mem,0,2**`PROG_RAM_ADDR_W-1);
    end

   //instruction port
   always @(posedge clk) begin			
      if (instr_en) begin
	 instruction <= mem[pc];
      end
   end
   
   //data port
   always @(posedge clk) begin			
      if (data_en_int) begin
	 if (data_we_int)
           mem[data_addr_int] <= data_in_int;
	 data_out_int <= mem[data_addr_int];
      end
   end

endmodule
