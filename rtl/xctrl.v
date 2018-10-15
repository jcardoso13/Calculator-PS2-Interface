`timescale 1ns / 1ps

`include "xdefs.vh"
`include "xctrldefs.vh"
`include "xprogdefs.vh"

module xctrl (
	      input 			    clk,
	      input 			    rst,
	      
	      // Program memory interface
	      output reg [`PROG_ADDR_W-1:0] pc,
	      input [`INSTR_W-1:0] 	    instruction,
	      
	      // Data memory interface 
	      output reg		    data_sel,
	      output reg 		    data_we,
	      output reg [`ADDR_W-1:0] 	    data_addr,
	      input [`DATA_W-1:0] 	    data_to_rd,
	      output [`DATA_W-1:0] 	    data_to_wr
	      );
   
   reg [`DATA_W-1:0] 			  data_to_rd_int;
   
   reg [`DATA_W-1:0] 			  regA;
   reg [`DATA_W-1:0] 			  regA_nxt;
   reg [`DATA_W:0] 			  temp_regA;


   // Data pointer register (register B)
   reg 					  regB_sel;
   wire 				  regB_we;
   reg [`DATA_W-1:0] 			  regB;
   wire [`DATA_W-1:0] 			  regB_nxt;
   wire [`ADDR_W-1:0] 			  addr_from_regB;

   //carry register (register C)
   wire [`DATA_W-1:0] 			  regC;
   reg 					  cs;
   reg 					  cs_nxt;

   // Program counter 
   reg [`PROG_ADDR_W-1:0] 		  pc_nxt;
   
   // Instruction fields
   wire [`OPCODESZ-1 :0] 		  opcode;
   wire [`ADDR_W-1:0] 			  addrint;
   wire signed [`DATA_W-1:0] 		  imm;
   
    
   // Instruction field assignment
   assign opcode  = instruction[`INSTR_W-1 -: `OPCODESZ];
   assign addrint = instruction[`ADDR_W-1:0];
   assign imm     = {{(`DATA_W-`IMM_W){instruction[`IMM_W-1]}},instruction[`IMM_W-1:0]};

   // data bus write value assignment
   assign data_to_wr = regA;

   // data pointer register assignment
   assign regB_we = regB_sel & data_we;
   assign regB_nxt = regB_we ? data_to_wr : regB;
   assign addr_from_regB = regB[`ADDR_W-1:0];

   // carry register assignment
   assign regC = {{(`DATA_W-1){1'b0}},cs};
   
   // Internal register address decoder
   always @ * begin
      regB_sel = 1'b0;
      if (data_addr == `RB) begin
	 regB_sel = 1'b1;
         data_to_rd_int = regB;
      end else if (data_addr == `RC)
	data_to_rd_int = regC;
      else
        data_to_rd_int = data_to_rd;
   end
   
   // Registers' update
   always @ (posedge clk) begin
      if (rst) begin
	 regA <= `DATA_W'd0;
	 cs   <= 1'b0;
	 pc   <= `PROG_ROM;
      end else begin
	 regA <= regA_nxt;
	 cs   <= cs_nxt;
	 pc   <= pc_nxt;
	 if(regB_we)
	   regB <= regB_nxt;     
      end
   end


   // Instruction decoder
   always @ * begin

      regA_nxt = regA;
      cs_nxt   = cs;
      pc_nxt   = pc + 1'b1;
      
      case (opcode)
	`RDW: begin
	   regA_nxt = data_to_rd_int;
	end
	`RDWB: begin
	   regA_nxt = data_to_rd_int;
	end
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
	   if ( regA == `DATA_W'd0 )
	     pc_nxt = pc + imm[`PROG_ADDR_W:0];
	end
	`BEQ: begin
	   regA_nxt = regA - `DATA_W'd1;
	   if ( regA == `DATA_W'd0 )
	     pc_nxt = regB[`PROG_ADDR_W:0];
	end
	`BNEQI: begin
	   regA_nxt = regA - `DATA_W'd1;
	   if ( regA != `DATA_W'd0 )
	     pc_nxt = pc + imm[`PROG_ADDR_W:0];
	end
	`BNEQ: begin
	   regA_nxt = regA - `DATA_W'd1;
	   if ( regA != `DATA_W'd0 )
	     pc_nxt = regB[`PROG_ADDR_W:0];
	end
	`LDI: begin
	   regA_nxt = imm;
	end
	`LDIH: begin
	   regA_nxt = {imm[`DATA_W-`IMM_W-1:0],regA[`IMM_W-1:0]};
	end
	`ADD: begin
	   regA_nxt  = temp_regA[`DATA_W-1:0];
	   cs_nxt    = temp_regA[`DATA_W];
	end
	`SUB: begin
	   regA_nxt  = temp_regA[`DATA_W-1:0];
	   cs_nxt    = temp_regA[`DATA_W];
	end
	`ADDI: begin
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


   // adder / subtractor
   always @* begin
      case (opcode)
	`SUB: temp_regA = regA - data_to_rd_int;
	`ADDI: temp_regA = regA + imm;
	default: temp_regA = regA + data_to_rd_int;
      endcase
   end

   
   //data bus access
   always @ * begin

      data_sel  = 1'b0;
      data_we  = 1'b0;
      data_addr = addrint;
      
      case (opcode)
	`RDW: begin 
	   data_sel  = (addrint >= `REGF_BASE);
	end
	`RDWB: begin
	   data_sel  = (addrint >= `REGF_BASE);
	   data_addr = addr_from_regB + imm;
	end
	`WRW: begin
	   data_sel  = (addrint >= `REGF_BASE);
	   data_we  = 1'b1;
	end
	`WRWB: begin
	   data_sel  = (addrint >= `REGF_BASE);
	   data_we = 1'b1;
	   data_addr = addr_from_regB + imm;
	end
	default:
	     data_we  = 1'b0;
      endcase
   end // always @ *
   
endmodule
