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
	     output [7:0] 	leds,
		  output [6:0]		sevenseg,
		  output				dp,
		  output	[3:0]		anodes,
/*		  output [`DATA_W-1:0] par_out,
		  input [`DATA_W-1:0] par_in,*/

	     //MANDATORY INTERFACE SIGNALS
	     input 		      clk,
	     input 		      rst,
		  
		  input			PS2_CLK,
	     input			PS2_DATA

	     );

   //
   //
   // CONNECTION WIRES
   //
   //
	
	
	wire [`DATA_W-1:0]      par_in;
	wire [`DATA_W-1:0]     par_out;
   
   // PROGRAM MEMORY/CONTROLLER INTERFACE
   wire [`INSTR_W-1:0] 		  instruction;
   wire [`PROG_ADDR_W-1:0] 	  pc;

   // DATA BUS
   wire 			  data_sel;
   wire 			  data_we;
   wire [`ADDR_W-1:0] 		  data_addr;
   reg [`DATA_W-1:0] 		  data_to_rd;
   wire [`DATA_W-1:0] 		  data_to_wr;
	
	reg	[15:0]				  displayed_number; //number to be displayed

   // MODULE SELECTION SIGNALS
   reg 				  prog_sel;
   wire [`DATA_W-1:0] 		  prog_data_to_rd;
   
   reg 				  regf_sel;
   wire [`DATA_W-1:0] 		  regf_data_to_rd;
	
	reg	[7:0]				led_sel;
	reg					display_sel;
   reg ps2_sel;
   wire [10:0]			ps2_data_to_rd;
   wire ps2_done;
   reg ps2_rst;
   reg [7:0] led_input;

   
`ifdef DEBUG
   reg 				  cprt_sel;
`endif
   
   
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
		     
		     // Data bus
		     .data_sel(data_sel),
		     .data_we (data_we), 
		     .data_addr(data_addr),
		     .data_to_rd(data_to_rd), 
		     .data_to_wr(data_to_wr)
		     );

   // PROGRAM MEMORY MODULE
   xprog prog (
	       .clk(clk),

	       //data interface 
	       .data_sel(prog_sel),
	       .data_we(data_we),
	       .data_addr(data_addr[`PROG_RAM_ADDR_W-1:0]),
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
		display_sel = 1'b0;
		led_sel = 8'b0;
		ps2_rst =1'b0;
`ifdef DEBUG
      cprt_sel = 1'b0;
`endif
      data_to_rd = `DATA_W'd0;
      
      if (`REGF_BASE == (data_addr & ({`ADDR_W{1'b1}}<<`REGF_ADDR_W))) begin
	 regf_sel = data_sel;
         data_to_rd = regf_data_to_rd;
      end
`ifdef DEBUG
      else if (`CPRT_BASE == data_addr)
	 cprt_sel = data_sel;
 `endif
     else if (`PROG_BASE == (data_addr & ({`ADDR_W{1'b1}}<<`PROG_ADDR_W))) begin
         prog_sel = 1'b1;
         data_to_rd = prog_data_to_rd;
			end
	  else if (`PS2_BASE == data_addr) begin
		  ps2_rst=1'b1;
		  data_to_rd[10:0] = ps2_data_to_rd;
		  data_to_rd[31:11] = 21'd0;
		  end
	  else if (`PS2_BASE+1 == data_addr) begin
			ps2_sel= data_sel;
			data_to_rd[0]= ps2_done;
			data_to_rd[31:1]=31'd0;
			end
	  else if (`DISPLAY_BASE == data_addr) begin
			display_sel = 1'b1;
			displayed_number = data_to_wr[15:0];
			end
    else if (`LED_BASE == data_addr) begin
			led_sel = data_to_wr[15:8];
			led_input = data_to_wr[7:0];
			end			
						
		
`ifdef DEBUG	
     else if(data_sel === 1'b1)
       $display("Warning: unmapped controller issued data address %x at time %f", data_addr, $time);
`endif
   end 
	// always @ *

   //
   //
   // USER MODULES INSERTED BELOW
   //
   //
   //agora nao preciso o dp
	assign dp = 1'b1;
	
	
	xps2 ps2 (
		.PS2_CLK(PS2_CLK),
		.PS2_DATA(PS2_DATA),
		.clk(clk),
		.rst(ps2_rst),
		.data_out(ps2_data_to_rd)
		//.datafetched(ps2_done)
	);

	
	xseven_seg_display seven_seg_display(
		.clk(clk),
		.reset(rst),
		.Anode_Activate(anodes),
		.LED_out(sevenseg),
		.dp(dp),
		.displayed_number(displayed_number),
		.display_sel(display_sel)
	);
   
	xleds FPGA_leds(
		.clk(clk),
		.reset(rst),
		.leds(leds),
		.led_input(ps2_data_to_rd),
		.leds_sel(8'hFF)
	);

	
	
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

`ifdef DEBUG
   xcprint cprint (
		   .clk(clk),
		   .sel(cprt_sel),
		   .data_in(data_to_wr[7:0])
		   );
`endif


	
endmodule
