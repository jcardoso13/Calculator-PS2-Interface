// Opcode size
`define OPCODESZ 4

// Instructions
`define RDW	4'h0 
`define WRW	4'h1 
`define RDWB	4'h2 
`define WRWB	4'h3 
`define BEQI	4'h4 
`define BEQ	4'h5 
`define BNEQI	4'h6 
`define BNEQ	4'h7 
`define LDI     4'h8 
`define LDIH    4'h9 
`define SHFT    4'hA 
`define ADD	4'hB 
`define ADDI	4'hC 
`define SUB	4'hD 
`define AND	4'hE 
`define XOR	4'hF 
// Uncomment this line if INT_ADDR_W greater then DATA_W
`define INTADDRWGTDATAW

// Data width
`define DATA_W 8 // bits

// 2**10 = 1024 internal addresses
`define INT_ADDR_W 10

// Program memory address width
`define IADDR_W 10 // 2**10 = 1024 boot instructions

// Instructions
// Instruction fields
`define INSTR_W 8
`define IMM_W (`INSTR_W-`OPCODESZ) //4

//Index
`define ROM_BASE `IADDR_W'd0
