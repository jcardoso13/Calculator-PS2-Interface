/* ****************************************************************************
 This Source Code Form is subject to the terms of the
 Open Hardware Description License, v. 1.0. If a copy
 of the OHDL was not distributed with this file, You
 can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

 Description: 

 Copyright (C) 2014 Authors

 Author(s): Jose T. de Sousa <jose.t.de.sousa@gmail.com>
            Andre Lopes <andre.a.lopes@netcabo.pt>
            Guilherme Luz <gui_luz_93@hotmail.com>
            Joao Dias lopes <joao.d.lopes91@gmail.com>
            Francisco Nunes <ftcnunes@gmail.com>

 ***************************************************************************** */

`timescale 1ns / 1ps

`include "xdefs.v"
`include "xmem_map.v"

`define RB0 `INT_ADDR_W'd0
`define RB1 `INT_ADDR_W'd1
`define RC `INT_ADDR_W'd2

module xctrl (
	      input 			   clk,
	      input 			   rst,
	      
	      // Program memory interface 
	      input [`INSTR_W-1:0] 	   instruction,
	      output reg [`IADDR_W:0] 	   pc,
	      
	      // Read/write interface 
	      output reg 		   rw_req,
	      output reg 		   rw_rnw,
	      output reg [`INT_ADDR_W-1:0] rw_addr,
	      input [`DATA_W-1:0] 	   data_to_rd,
	      output [`DATA_W-1:0] 	   data_to_wr
	      );
   
   reg 					   rw_req_int;
   reg [`DATA_W-1:0] 			   data_to_rd_int;
   
   reg [`DATA_W-1:0] 			   regA;
   reg [`DATA_W-1:0] 			   regA_nxt;
   reg [`DATA_W:0] 			   temp_regA;
   
   reg 					   regB0_req;
   reg 					   regB1_req;
   wire 				   regB_we;
   reg [2*`DATA_W-1:0] 			   regB;
   wire [2*`DATA_W-1:0] 		   regB_nxt;
   wire [`INT_ADDR_W-1:0] 		   regB_int;
   
   wire [`DATA_W-1:0] 			   regC;
   reg 					   cs;
   reg 					   cs_nxt;
   
   reg [`IADDR_W:0] 			   pc_nxt;
   
   // Instruction fields
   wire [`OPCODESZ-1 :0] 		   opcode;
   wire [`INT_ADDR_W-1:0] 		   addrint;
   wire signed [`DATA_W-1:0] 		   imm;
   
   // Instruction field assignment
   assign opcode  = instruction[`INSTR_W-1 -: `OPCODESZ];
`ifdef INTADDRWGTDATAW
   assign addrint = {{(`INT_ADDR_W-`INSTR_W+`OPCODESZ){1'b0}},instruction[`INSTR_W-`OPCODESZ-1:0]};
`else
   assign addrint = instruction[`INT_ADDR_W-1:0];
`endif
   assign imm     = {{(`DATA_W-`IMM_W){instruction[`IMM_W-1]}},instruction[`IMM_W-1:0]};
   
   assign data_to_wr = regA;
   
   assign regB_we = (regB0_req | regB1_req) & ~rw_rnw;
   assign regB_nxt = (regB0_req == 1'b0) ? {data_to_wr,regB[`DATA_W-1:0]} : {regB[2*`DATA_W-1 -: `DATA_W],data_to_wr};
   assign regB_int = regB[`INT_ADDR_W-1:0];
   
   assign regC = {{(`DATA_W-1){1'b0}},cs};
   
   // address decoder
   always @ * begin
      rw_req = rw_req_int;
      regB0_req = 1'b0;
      regB1_req = 1'b0;
      
      if (rw_addr == `RB0) begin
	 rw_req = 1'b0;
	 regB0_req = rw_req_int;
         data_to_rd_int = regB[`DATA_W-1 : 0];
      end else if (rw_addr == `RB1) begin
	 rw_req = 1'b0;
	 regB1_req = rw_req_int;
	 data_to_rd_int = regB[2*`DATA_W-1 -: `DATA_W];
      end else if (rw_addr == `RC) begin
	 rw_req = 1'b0;
	 data_to_rd_int = regC;
      end else begin
         data_to_rd_int = data_to_rd;
      end
   end
   
   // Registers
   always @ (posedge clk, posedge rst)
     if (rst) begin 
	regA <= `DATA_W'd0;
	cs   <= 1'b0;
	pc   <= `ROM_BASE;
     end else begin
	regA <= regA_nxt;
	cs   <= cs_nxt;
	pc   <= pc_nxt;
     end
   
   always @ (posedge clk)
     if(regB_we)
       regB <= regB_nxt;
   
   always @ * begin
      regA_nxt = regA;
      cs_nxt   = cs;
      pc_nxt   = pc + 1'b1;
      
      case (opcode)
	`RDW: begin
	   regA_nxt = data_to_rd_int;
	end
	//`WRW: begin
	//end
	`RDWB: begin
	   regA_nxt = data_to_rd_int;
	end
	//`WRWB: begin
	//end
	`SHFT: begin
	   if ( imm[`DATA_W-1] ) begin
	      regA_nxt = regA << 1'b1;
	      cs_nxt   = regA[`DATA_W-1];
	   end else begin
	      regA_nxt = regA >> 1'b1;
	      cs_nxt   = regA[0];
	   end
	end
	`BEQI: begin
	   regA_nxt = regA - `DATA_W'd1;
	   if ( regA[`DATA_W-1:0] == `DATA_W'd0 )
`ifdef INTADDRWGTDATAW
	     pc_nxt = pc + {{(`IADDR_W-`DATA_W+1){imm[`DATA_W-1]}},imm};
`else
	     pc_nxt = pc + imm[`IADDR_W:0];
`endif
	end
	`BEQ: begin
	   regA_nxt = regA - `DATA_W'd1;
	   if ( regA[`DATA_W-1:0] == `DATA_W'd0 )
	     pc_nxt = regB[`IADDR_W:0];
	end
	`BNEQI: begin
	   regA_nxt = regA - `DATA_W'd1;
	   if ( regA[`DATA_W-1:0] != `DATA_W'd0 )
`ifdef INTADDRWGTDATAW
	     pc_nxt = pc + {{(`IADDR_W-`DATA_W+1){imm[`DATA_W-1]}},imm};
`else
	     pc_nxt = pc + imm[`IADDR_W:0];
`endif
	end
	`BNEQ: begin
	   regA_nxt = regA - `DATA_W'd1;
	   if ( regA[`DATA_W-1:0] != `DATA_W'd0 )
	     pc_nxt = regB[`IADDR_W:0];
	end
	`LDI: begin
	   regA_nxt = imm;
	end
	`LDIH: begin
	   regA_nxt = {imm[`DATA_W-`IMM_W-1:0],regA[`IMM_W-1:0]};
	end
	`ADD: begin
	   temp_regA = regA + data_to_rd_int;
	   regA_nxt  = temp_regA[`DATA_W-1:0];
	   cs_nxt    = temp_regA[`DATA_W];
	end
	`SUB: begin
	   temp_regA = regA - data_to_rd_int;
	   regA_nxt  = temp_regA[`DATA_W-1:0];
	   cs_nxt    = temp_regA[`DATA_W];
	end
	`ADDI: begin
	   temp_regA = regA + imm;
	   regA_nxt  = temp_regA[`DATA_W-1:0];
	   cs_nxt    = temp_regA[`DATA_W];
	end
	`AND: begin
	   regA_nxt = regA & data_to_rd_int;
	end
	`XOR: begin
	   regA_nxt = regA ^ data_to_rd_int;
	end
	default:
	  pc_nxt = pc + 1'b1;
      endcase
   end
   
   always @ * begin
      rw_req_int  = 1'b0;
      rw_rnw  = 1'b1;
      rw_addr = addrint;
      
      case (opcode)
	`RDW: begin
	   rw_req_int  = 1'b1;
	end
	`RDWB: begin
	   rw_req_int  = 1'b1;
	   rw_rnw  = 1'b1;
	   rw_addr = regB_int + imm;
	end
	`WRW: begin
	   rw_req_int  = 1'b1;
	   rw_rnw  = 1'b0;
	end
	`WRWB: begin
	   rw_req_int  = 1'b1;
	   rw_rnw  = 1'b0;
	   rw_addr = regB_int + imm;
	end
	`ADD: begin
	   rw_req_int  = 1'b1;
	end
	`SUB: begin
	   rw_req_int  = 1'b1;
	end
	`AND: begin
	   rw_req_int  = 1'b1;
	end
	`XOR: begin
	   rw_req_int  = 1'b1;
	end
	default:
	  rw_req_int   = 1'b0;
      endcase
   end
   
endmodule
