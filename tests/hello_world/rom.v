`PROG_ROM_ADDR_W'h0: data <= `INSTR_W'h60000;
`PROG_ROM_ADDR_W'h1: data <= `INSTR_W'h90010;
`PROG_ROM_ADDR_W'h2: data <= `INSTR_W'h80010;
`PROG_ROM_ADDR_W'h3: data <= `INSTR_W'hcfffe;
`PROG_ROM_ADDR_W'h4: data <= `INSTR_W'h00000;
`PROG_ROM_ADDR_W'h5: data <= `INSTR_W'he00fa;
`PROG_ROM_ADDR_W'h6: data <= `INSTR_W'h00000;
default: data <= `INSTR_W'h00000;