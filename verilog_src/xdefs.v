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

