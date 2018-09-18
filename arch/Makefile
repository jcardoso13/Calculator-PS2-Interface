# definitions
VC = iverilog
CFLAGS = -W all -I. -g2005-sv
SRC = pico_versat.v pico_versat_tb.v
TRGT = picoVersat

# rules
$(TRGT): $(SRC)
	$(VC) $(CFLAGS) -o $@ $(SRC)
	./$@

clean:
	@rm -f $(TRGT) $(TRGT).vcd *# *~

.phony: clean
