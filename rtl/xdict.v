/*
 Descrition: generates a dictionary of symbols for the assembler
 */

`timescale 1ns / 1ps
`include "xdefs.vh"
`include "xctrldefs.vh"
`include "xregfdefs.vh"
`include "xprogdefs.vh"

module xdict;

   integer fp, i;

   initial begin

      fp = $fopen("xdict.txt","w");

      $fwrite(fp,"{\n");

      //
      // CONTROLLER
      //
      
      //immediate width       
      $fwrite(fp, "\"IMM_W\":%d,\n", `IMM_W);
  
      //delay slots
      $fwrite(fp, "\"DELAY_SLOTS\":%d,\n", `DELAY_SLOTS);

      //instruction codes
      $fwrite(fp, "\"shft\":%d,\n", `SHFT);
      $fwrite(fp, "\"add\":%d,\n", `ADD);
      $fwrite(fp, "\"addi\":%d,\n", `ADDI);
      $fwrite(fp, "\"sub\":%d,\n", `SUB);
      $fwrite(fp, "\"and\":%d,\n", `AND);
      $fwrite(fp, "\"xor\":%d,\n", `XOR);
      $fwrite(fp, "\"ldi\":%d,\n", `LDI);
      $fwrite(fp, "\"ldih\":%d,\n", `LDIH);
      $fwrite(fp, "\"rdw\":%d,\n", `RDW);
      $fwrite(fp, "\"wrw\":%d,\n", `WRW);
      $fwrite(fp, "\"rdwb\":%d,\n", `RDWB);
      $fwrite(fp, "\"wrwb\":%d,\n", `WRWB);
      $fwrite(fp, "\"beqi\":%d,\n", `BEQI);
      $fwrite(fp, "\"beq\":%d,\n", `BEQ);
      $fwrite(fp, "\"bneqi\":%d,\n", `BNEQI);
      $fwrite(fp, "\"bneq\":%d,\n", `BNEQ);

      // aliases 
      $fwrite(fp, "\"nop\":%d,\n", `ADDI);
      $fwrite(fp, "\"wrc\":%d,\n", `WRW);

      
      //
      // PROG
      //
          
      $fwrite(fp, "\"INSTR_W\":%d,\n", `INSTR_W);
      $fwrite(fp, "\"PROG_ADDR_W\":%d,\n", `PROG_ADDR_W);

  
      //
      //
      // MEMORY MAP
      //
      //

      // Controller
      $fwrite(fp, "\"RB\":%d,\n", `RB);
      $fwrite(fp, "\"RC\":%d,\n", `RC);
      
      
      // Registers 
      $fwrite(fp, "\"R0\":%d,\n", `R0);
      $fwrite(fp, "\"R1\":%d,\n", `R1);
      $fwrite(fp, "\"R2\":%d,\n", `R2);
      $fwrite(fp, "\"R3\":%d,\n", `R3);
      $fwrite(fp, "\"R4\":%d,\n", `R4);
      $fwrite(fp, "\"R5\":%d,\n", `R5);
      $fwrite(fp, "\"R6\":%d,\n", `R6);
      $fwrite(fp, "\"R7\":%d,\n", `R7);
      $fwrite(fp, "\"R8\":%d,\n", `R8);
      $fwrite(fp, "\"R9\":%d,\n", `R9);
      $fwrite(fp, "\"R10\":%d,\n", `R10);
      $fwrite(fp, "\"R11\":%d,\n", `R11);
      $fwrite(fp, "\"R12\":%d,\n", `R12);
      $fwrite(fp, "\"R13\":%d,\n", `R13);
      $fwrite(fp, "\"R14\":%d,\n", `R14);
      $fwrite(fp, "\"R15\":%d,\n", `R15);

      // Program memory 
      $fwrite(fp, "\"PROG_ROM\":%d,\n", `PROG_ROM);
      $fwrite(fp, "\"PROG_ROM_ADDR_W\":%d,\n", `PROG_ROM_ADDR_W);
      $fwrite(fp, "\"PROG_RAM\":%d,\n", `PROG_RAM);
      $fwrite(fp, "\"PROG_RAM_ADDR_W\":%d,\n", `PROG_RAM_ADDR_W);
      // used as data memory
      $fwrite(fp, "\"PROG_BASE\":%d,\n", `PROG_BASE); 

      // Char print module
      $fwrite(fp, "\"CPRT_BASE\":%d,\n", `CPRT_BASE);


      // Finish writing dictionary
      $fwrite(fp,"}\n");
      $fclose(fp);

   end

endmodule
