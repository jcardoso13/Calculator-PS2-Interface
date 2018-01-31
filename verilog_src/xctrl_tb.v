/* ****************************************************************************
  This Source Code Form is subject to the terms of the
  Open Hardware Description License, v. 1.0. If a copy
  of the OHDL was not distributed with this file, You
  can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

  Description: 

   Copyright (C) 2014 Authors

  Author(s): Jose T. de Sousa <jose.t.de.sousa@gmail.com>
             Joao Dias Lopes <joao.d.lopes91@gmail.com>
             Andre Lopes <andre.a.lopes@netcabo.pt>

***************************************************************************** */

`timescale 1ns / 1ps

`include "xdefs.v"

module xctrl_tb;
   
   //parameters 
   parameter clk_period = 10;
   
   // Inputs
   reg clk;
   reg rst;
   reg [`INSTR_W-1:0]     instruction;
   reg [`DATA_W-1:0]      data_to_rd;
   reg 			  regB_req;
   
   // Outputs
   wire [`IADDR_W-1:0]    pc;
   wire 	          rw_req;
   wire 	          rw_rnw;
   wire [`INT_ADDR_W-1:0] rw_addr;
   wire [`DATA_W-1:0] 	  data_to_wr;
   wire [`DATA_W-1:0] 	  regB;
   wire [`DATA_W-1:0] 	  cs;
   
   // Instantiate the Unit Under Test (UUT)
   xctrl uut (
	      .clk(clk),
              .rst(rst),
	      
              .instruction(instruction),
	      .pc(pc),
	      
              .rw_req(rw_req),
              .rw_rnw(rw_rnw),
              .rw_addr(rw_addr),
              .data_to_rd(data_to_rd),
	      .data_to_wr(data_to_wr),
	      
	      .regB_req(regB_req),
	      .regB(regB),
	      
	      .cs(cs)
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
      
      // Wait for global reset to finish
      #(clk_period+1)
      rst = 1;
      #clk_period;
      rst = 0;
      
      // Add stimulus here
      // Test WRW and LDI functions
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `LDI;
      instruction[0 +: `IMM_W] = `IMM_W'd3;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `WRW;
      instruction[0 +: `IMM_W] =`IMM_W'd6;
      
      // Test load and store functions
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `LDI;
      instruction[0 +: `IMM_W] = `IMM_W'd2;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `WRW;
      instruction[0 +: `IMM_W] =`IMM_W'd5;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `LDI;
      instruction[0 +: `IMM_W] = `IMM_W'h8;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R0
      instruction[0 +: `IMM_W] = `IMM_W'h0;
      data_to_rd = `DATA_W'hA5;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add R1
      instruction[0 +: `IMM_W] = `IMM_W'h1;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R2
      instruction[0 +: `IMM_W] = `IMM_W'h2;
      data_to_rd = `DATA_W'h5A;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add R3
      instruction[0 +: `IMM_W] = `IMM_W'h3;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add carry
      instruction[0 +: `IMM_W] = `IMM_W'h4;
      data_to_rd = `DATA_W'd1;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R0
      instruction[0 +: `IMM_W] = `IMM_W'h0;
      data_to_rd = `DATA_W'hA5;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // sub R1
      instruction[0 +: `IMM_W] = `IMM_W'h1;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R2
      instruction[0 +: `IMM_W] = `IMM_W'h2;
      data_to_rd = `DATA_W'h5A;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // sub R3
      instruction[0 +: `IMM_W] = `IMM_W'h3;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add carry
      instruction[0 +: `IMM_W] = `IMM_W'h4;
      data_to_rd = `DATA_W'd1;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADDI; // add -1
      instruction[0 +: `IMM_W] = `IMM_W'hF;
      
      // Simulation time 1000 ns
      #(2*clk_period) $finish;
      
   end
   
   always 
     #(clk_period/2) clk = ~clk;
   
endmodule

