`timescale 1ns / 1ps

`include "xdefs.v"

module xctrl_tb;
   
   //parameters 
   parameter clk_period = 10;
   
   // Inputs
   reg clk;
   reg rst;
   reg [`INSTR_W-1:0]     instruction;
   reg 			  instr_valid;
   reg [`DATA_W-1:0]      data_to_rd;
   
   // Outputs
   wire [`IADDR_W:0] 	  pc;
   wire 	          rw_req;
   wire 	          rw_rnw;
   wire [`INT_ADDR_W-1:0] rw_addr;
   wire [`DATA_W-1:0] 	  data_to_wr;
   
   // Instantiate the Unit Under Test (UUT)
   xctrl uut (
	      .clk(clk),
              .rst(rst),
	      
	      .pc(pc),
	      .instr_valid(instr_valid),
	      .instruction(instruction),
	      
              .rw_req(rw_req),
              .rw_rnw(rw_rnw),
              .rw_addr(rw_addr),
              .data_to_rd(data_to_rd),
	      .data_to_wr(data_to_wr)
	      );
   
   initial begin
      // Global reset of FPGA
      #100
      
`ifdef DEBUG
      $dumpfile("xctrl.vcd");
      $dumpvars();
`endif
      
      // Initialize Inputs
      clk = 0;
      rst = 0;
      instruction = 0;
      instr_valid = 1;
      
      // Wait for global reset to finish
      #(clk_period+1)
      rst = 1;
      #clk_period;
      rst = 0;
      
      // Add stimulus here
      // Test WRW and LDI functions
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `LDI;
      instruction[0 +: `IMM_W] = 3;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `WRW;
      instruction[0 +: `IMM_W] = 6;
      
      // Test load and store functions
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `LDI;
      instruction[0 +: `IMM_W] = 2;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `WRW;
      instruction[0 +: `IMM_W] = 5;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `LDI;
      instruction[0 +: `IMM_W] = 8;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R0
      instruction[0 +: `IMM_W] = 3;
      data_to_rd = `DATA_W'hA5;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add R1
      instruction[0 +: `IMM_W] = 4;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R2
      instruction[0 +: `IMM_W] = 5;
      data_to_rd = `DATA_W'h5A;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add carry
      instruction[0 +: `IMM_W] = 2;
      data_to_rd = `DATA_W'd3;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add R3
      instruction[0 +: `IMM_W] = 6;
      data_to_rd = `DATA_W'h5A;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R0
      instruction[0 +: `IMM_W] = 3;
      data_to_rd = `DATA_W'hA5;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // sub R1
      instruction[0 +: `IMM_W] = 4;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R2
      instruction[0 +: `IMM_W] = 5;
      data_to_rd = `DATA_W'h5A;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add carry
      instruction[0 +: `IMM_W] = 2;
      data_to_rd = `DATA_W'd3;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // sub R3
      instruction[0 +: `IMM_W] = 6;
      data_to_rd = `DATA_W'h5A;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADDI; // add -1
      instruction[0 +: `IMM_W] = -1;
      
      // Simulation time 1000 ns
      #(2*clk_period) $finish;
      
   end
   
   always 
     #(clk_period/2) clk = ~clk;
   
endmodule

