VC = iverilog
CFLAGS = -W all -I. -g2005-sv

SRC = pico_versat.v pico_versat_tb.v
TRGT = picoVersat

picoVersat: $(SRC) FORCE
	$(CC) $(CFLAGS) $(rundefs) -o $@ $(SRC)
	./$@

clean:
	@rm -f $(TRGT), $(TRGT).vcd, $(TRGT).vvp, *#, *~

.phony: clean
