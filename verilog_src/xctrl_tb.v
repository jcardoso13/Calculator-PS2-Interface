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
   
   integer 		  error;
   
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
      
      error = 0;
      
      // Initialize Inputs
      clk = 0;
      rst = 0;
      instruction = `INSTR_W'hC0; // NOP instruction
      instr_valid = 1;
      
      // Wait for global reset to finish
      #(clk_period+1)
      rst = 1;
      #clk_period;
      rst = 0;
      
      // Add stimulus here
      // Test load and store functions
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `LDI;
      instruction[0 +: `IMM_W] = 3;
      
      #1;
      if (instr_int != instruction) begin
	 error = 1;
      end
      
      #(clk_period-1)
      instruction[`INSTR_W-1 -:`OPCODESZ] = `WRW;
      instruction[0 +: `IMM_W] = 6;
      
      #1;
      if ((data_to_wr != imm_reg) || (rw_addr != instruction[0 +: `IMM_W])) begin
	 error = 1;
      end
      
      #(clk_period-1)
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW;
      instruction[0 +: `IMM_W] = 7;
      data_to_rd = `DATA_W'h55;
      
      #1;
      if (data_to_rd_int != data_to_rd) begin
	 error = 1;
      end
      
      // 16-bit words addition
      #(clk_period-1)
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
      
      if (regA != (regA_reg + data_to_rd_reg)) begin
	 error = 1;
      end
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add carry
      instruction[0 +: `IMM_W] = 2;
      
      #1;
      if (data_to_rd_int != regC) begin
	 error = 1;
      end
      
      #(clk_period-1)
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add R3
      instruction[0 +: `IMM_W] = 6;
      
      // 16-bit words subtraction
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R0
      instruction[0 +: `IMM_W] = 3;
      data_to_rd = `DATA_W'hA5;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `SUB; // sub R1
      instruction[0 +: `IMM_W] = 4;
      data_to_rd = `DATA_W'h5A;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `RDW; // read R2
      instruction[0 +: `IMM_W] = 5;
      data_to_rd = `DATA_W'hA5;
      
      if (regA != (regA_reg - data_to_rd_reg)) begin
	 error = 1;
      end
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADD; // add carry
      instruction[0 +: `IMM_W] = 2;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADDI; // add -1
      instruction[0 +: `IMM_W] = -1;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `SUB; // sub R3
      instruction[0 +: `IMM_W] = 6;
      data_to_rd = `DATA_W'h5A;
      
      // Stall controller
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADDI; // add -1
      instruction[0 +: `IMM_W] = -1;
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADDI; // add -2
      instruction[0 +: `IMM_W] = -2;
      instr_valid = 0;
      
      if (regA != (regA_reg + imm_reg)) begin
	 error = 1;
      end
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADDI; // add -3
      instruction[0 +: `IMM_W] = -3;
      
      if (regA != regA_reg) begin
	 error = 1;
      end
      
      #(3*clk_period)
      instr_valid = 1;
      
      if (regA != regA_reg) begin
	 error = 1;
      end
      
      #clk_period;
      instr_valid = 0;
      
      if (regA != (regA_reg + imm_reg)) begin
	 error = 1;
      end
      
      #clk_period;
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADDI; // add -4
      instruction[0 +: `IMM_W] = -4;
      
      if (regA != regA_reg) begin
	 error = 1;
      end
      
      #(3*clk_period)
      instr_valid = 1;
      
      #(2*clk_period)
      instruction[`INSTR_W-1 -:`OPCODESZ] = `ADDI; // add 1
      instruction[0 +: `IMM_W] = 1;
      
      if (regA != (regA_reg + imm_reg)) begin
	 error = 1;
      end
      
      if (error == 0) begin
	 $display("Test pass");
      end else begin
	 $display("Test fail!");
      end
      
      // Simulation time 1000 ns
      #(4*clk_period) $finish;
      
   end
   
   always 
     #(clk_period/2) clk = ~clk;
   
`ifndef	SYNTH
   wire [`DATA_W-1:0]        regA, regC, imm, data_to_rd_int;
   reg [`DATA_W-1:0] 	     imm_reg, data_to_rd_reg, regA_reg;
   wire [2*`DATA_W-1:0]      regB;
   wire [`INSTR_W-1:0] 	     instr_int, instr_reg;
   
   assign instr_int = uut.instruction_int2;
   assign instr_reg = uut.instruction_reg;
   assign imm = uut.imm;
   assign data_to_rd_int = uut.data_to_rd_int;
   assign regA = uut.regA;
   assign regB = uut.regB;
   assign regC = uut.regC;
   
   always @ (posedge clk) begin
      if (instr_valid)
	imm_reg <= imm;
      data_to_rd_reg <= data_to_rd_int;
      regA_reg <= regA;
   end
   
`endif
   
endmodule

