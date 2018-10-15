# definitions
VC = iverilog
CFLAGS = -W all -I. -g2005-sv -D DEBUG
SRC = xctrl.v xprog_ram.v xprog_rom.v xregf.v xcprint.v xprog.v xtop.v xtop_tb.v
XDEFS = $(wildcard *.vh)


# rules

# compile and run simulation object
xtop: $(SRC) bootrom.hex program.hex $(XDEFS)
	$(VC) $(CFLAGS) -o $@ $(SRC)
	./$@

# build symbol dictionary
xdict: xdict.v $(XDEFS)
	$(VC) $(CFLAGS) -o $@ xdict.v
	./$@

clean:
	@rm -f xtop xtop.vcd *# *~ xdict xdict.txt *.hex


.phony: clean
