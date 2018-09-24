//
// VERSAT CONTROLLER DEFINES
//

// Instruction width 
`define INSTR_W 20

// Instruction fields
`define OPCODESZ 4
`define IMM_W (`INSTR_W-`OPCODESZ) //16 = DATA_W

`define DELAY_SLOTS 1

// Instruction codes
`define SHFT    4'h0
`define ADD	4'h1
`define ADDI	4'h2
`define SUB	4'h3
`define AND	4'h4
`define XOR	4'h5

// load / store
`define LDI     4'h6
`define LDIH    4'h7
`define RDW	4'h8
`define WRW	4'h9
`define RDWB	4'hA
`define WRWB	4'hB

//branches
`define BEQI	4'hC
`define BEQ	4'hD
`define BNEQI	4'hE
`define BNEQ	4'hF

// Internal register addresses
`define RB0 `ADDR_W'd0
`define RB1 `ADDR_W'd1
`define RC `ADDR_W'd2
