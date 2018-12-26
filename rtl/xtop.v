`timescale 1ns / 1ps

`include "xdefs.vh"
`include "xctrldefs.vh"
`include "xprogdefs.vh"
`include "xregfdefs.vh"


module xtop (
	     //INSERT EXTERNAL INTERFACES HERE
	     // parallel interface
	     input par_we,
	     input [1:0] sw_in,
	     output [7:0] 	leds,
		  output [6:0]		sevenseg,
		  output				dp,
		  output	[3:0]		anodes,
/*		  output [`DATA_W-1:0] par_out,
		  input [`DATA_W-1:0] par_in,*/
		//output reg				finish,
	     //MANDATORY INTERFACE SIGNALS
	     input 		      clk,
	     input 		      rst,
	     input 			btn,
		  
		  input			PS2_CLK,
	     input			PS2_DATA

	     );

   //
   //
   // CONNECTION WIRES
   //
   //
	
	//DEBUG INIT
	//DEBUG END
	
	wire [`DATA_W-1:0]      par_in=32'hFFFFFFFF;
	wire [`DATA_W-1:0]     par_out;
	wire [`REGF_ADDR_W-1:0] par_addr=0;
	
   
   // PROGRAM MEMORY/CONTROLLER INTERFACE
   wire [`INSTR_W-1:0] 		  instruction;
   wire [`PROG_ADDR_W-1:0] 	  pc;

   // DATA BUS
   wire 			  data_sel;
   wire 			  data_we;
	wire 				ram_led;
   wire [`ADDR_W-1:0] 		  data_addr;
   reg [`DATA_W-1:0] 		  data_to_rd;
   wire [`DATA_W-1:0] 		  data_to_wr;
	
		wire [7:0] xxleds;

	
	reg	[31:0]				  displayed_number; //number to be displayed

   // MODULE SELECTION SIGNALS
   reg 				  prog_sel;
   wire [`DATA_W-1:0] 		  prog_data_to_rd;
   
   reg 				  regf_sel;
   wire [`DATA_W-1:0] 		  regf_data_to_rd;
	reg [31:0]				ps2_buff=0;
	
	reg	[7:0]				led_sel;
	reg					display_sel;
   wire [31:0]			ps2_data_to_rd1;
	wire [31:0]			ps2_data_to_rd2;
	wire [31:0]			ps2_data_to_rd3;
   wire ps2_done;
   reg ps2_rst;
   reg [7:0] led_input;
	reg[2:0] cnt_key=0;
	reg[31:0] reg1=0;
	reg[31:0] reg2=0;
	reg[31:0] reg3=0;
	reg[31:0] reg5=0;
	reg[31:0] reg6=0;
	reg data=1;
		

	//initial buffer = 1'b0;
   
`ifdef DEBUG
   reg 				  cprt_sel;
`endif
   
  /* always@(*) begin
   if (par_out!=1'b0)
		finish<=1'b1;
	end
   */
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
			 .ram_led(ram_led),

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
   always @ (*) begin
	
		
      prog_sel = 1'b0;
      regf_sel = 1'b0;
		display_sel = 1'b0;
		led_sel = 8'b0;
		displayed_number=0;
		reg5=reg6;
		
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
				data_to_rd=ps2_data_to_rd1;
	end
	else if(10'h31 == data_addr) begin
				data_to_rd=ps2_data_to_rd2;
	end
	else if(10'h32 == data_addr) begin
				data_to_rd=ps2_data_to_rd3;						  
	end
	  else if (`DISPLAY_BASE == data_addr) begin
			display_sel = 1'b1;
			
			displayed_number = data_to_wr;
			end
    else if (`LED_BASE == data_addr) begin
			led_sel = data_to_wr[15:8];
			led_input = data_to_wr[7:0];
			end			
	else if (`SW_BASE == data_addr) begin
			data_to_rd[31:2]=30'h0;
			data_to_rd[1:0]=sw_in;
			
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
		.data_rst(ps2_rst),
		.rst(rst),
		.data_out(ps2_data_to_rd1),
		.data_out2(ps2_data_to_rd2),
		.data_out3(ps2_data_to_rd3),
		.ps2_done(ps2_done)
	);

	
	xseven_seg_display seven_seg_display(
		.clk(clk),
		.reset(rst),
		.Anode_Activate(anodes),
		.LED_out(sevenseg),
		.dp(dp),
		.btn(btn),
		.displayed_number(displayed_number),
		.display_sel(display_sel)
	);
   
	xleds FPGA_leds(
		.clk(clk),
		.reset(rst),
		.leds(leds),
		.led_input(led_input),
		.ram_led(ram_led),
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
