//
// picoVersat system definitions
//

// DATA WIDTH
`define DATA_W 32 // bits

// ADDRESS WIDTH
`define ADDR_W 10

// DEBUG FLAG TO GENERATE VCD FILE
`define DEBUG

//
// VERSAT MEMORY MAP
//

//addresses 0-15 are reserved by the controler
`define REGF_BASE `ADDR_W'h010 //16-31
`define CPRT_BASE `ADDR_W'h020 //32
`define PROG_BASE `ADDR_W'h200 //512-1024
