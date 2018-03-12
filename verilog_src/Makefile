CC = iverilog
CFLAGS = -W all -I. -g2005-sv

BINS = \
$(wildcard xctrl)

TMP_FILES = \
$(wildcard xctrl.out)

VCDS = $(wildcard *.vcd)
SRC = xctrl.v xctrl_tb.v

all: xctrl

xctrl: $(SRC) FORCE
	$(CC) $(CFLAGS) $(rundefs) -o $@ $(SRC)
	./$@

clean:
	$(foreach fn,$(BINS),if [ -e $(fn) ]; then rm -f $(fn); fi;)
	$(foreach fn,$(VCDS),if [ -e $(fn) ]; then rm -f $(fn); fi;)
	$(foreach fn,$(TMP_FILES),if [ -e $(fn) ]; then rm -f $(fn); fi;)
	if [ -e *.vvp ]; then rm -f *.vvp; fi;
	if [ -e *.o ]; then rm -f *.o; fi;
	if [ -e *.vpi ]; then rm -f *.vpi; fi;
	if [ -e *# ]; then rm -f *#; fi;
	find .. -name \*~ -exec rm -f {} \;

FORCE: 

.phony: all clean FORCE
