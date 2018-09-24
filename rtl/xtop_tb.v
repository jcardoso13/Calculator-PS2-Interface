`timescale 1ns / 1ps

`include "xdefs.vh"

module xtop_tb;
   
   //parameters 
   parameter clk_period = 10;

   //
   // Interface signals
   //
   reg clk;
   reg rst;

   //parallel interface
   reg 	[`REGF_ADDR_W-1:0] par_addr;
   reg 			   par_we;
   reg [`DATA_W-1:0] 	   par_in;
   wire [`DATA_W-1:0] 	   par_out;

   //iterator and timer
   integer 		   k, start_time;

   // Testbench data memory
   reg [`DATA_W-1:0] data [2**`REGF_ADDR_W-1:0];
   
   // Instantiate the Unit Under Test (UUT)
   xtop uut (
	      .clk(clk),
              .rst(rst),
	      
   	     // parallel interface
	     .par_addr(par_addr),
	     .par_we(par_we),
	     .par_in(par_in),
	     .par_out(par_out)
    
	      );
   
   initial begin
      
`ifdef DEBUG
      $dumpfile("xtop.vcd");
      $dumpvars();
`endif
        
      // Initialize Inputs
      clk = 1;
      rst = 0;  
      
      // Initialize parallel interface
      par_addr = 0;
      par_we = 0;
      par_in = 0;

     // assert reset for 1 clock cycle
      #(clk_period+1)
      rst = 1;
      #clk_period;
      rst = 0;
      
      //
      // Run picoVersat
      //

      #(5*clk_period) par_addr = 0;
      par_we = 1;
      par_in = 1; //must be non-zero to jump to main program

      start_time = $time;

      #clk_period par_we = 0;
      par_addr = 0;

      //wait for versat to reset R0
      while(par_out != 0) #clk_period;

      $display("Execution time in clock cycles: %0d",($time-start_time)/clk_period);

      //
      // Dump reg file data to outfile
      //
      for (k = 0; k < 2**`REGF_ADDR_W; k=k+1) begin
	   data[k] = par_out;
	 #clk_period par_addr = par_addr + 1;
      end
  
      $writememh("data_out.hex", data, 0, 2**`REGF_ADDR_W - 1);

      //
      // End/pause simulation
      //
      #clk_period $finish;
      // #clk_period $stop;

   end // initial begin

   
   always 
     #(clk_period/2) clk = ~clk;

   // show registers
   wire [`DATA_W-1:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;

   assign r0 = uut.regf.reg_1[0];
   assign r1 = uut.regf.reg_1[1];
   assign r2 = uut.regf.reg_1[2];
   assign r3 = uut.regf.reg_1[3];
   assign r4 = uut.regf.reg_1[4];
   assign r5 = uut.regf.reg_1[5];
   assign r6 = uut.regf.reg_1[6];
   assign r7 = uut.regf.reg_1[7];
   assign r8 = uut.regf.reg_1[8];
   assign r9 = uut.regf.reg_1[9];
   assign r10 = uut.regf.reg_1[10];
   assign r11 = uut.regf.reg_1[11];
   assign r12 = uut.regf.reg_1[12];
   assign r13 = uut.regf.reg_1[13];
   assign r14 = uut.regf.reg_1[14];
   assign r15 = uut.regf.reg_1[15];  

endmodule

