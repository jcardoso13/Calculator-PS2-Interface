CC = iverilog
CFLAGS = -W all -I. -g2005-sv

BINS = \
$(wildcard xctrl)

TMP_FILES = \
$(wildcard xctrl.out)

VCDS = $(wildcard *.vcd)
INCLUDES = xdefs.v xmem_map.v xctrl.vh

ifneq ($(MAKECMDGOALS), clean)
FOO = $(MAKECMDGOALS)
TMP = $(MAKECMDGOALS).v $(MAKECMDGOALS)_tb.v
endif

ifeq ($(MAKECMDGOALS), xctrl)
SRC = $(TMP)
$(FOO): $(SRC) FORCE
	$(CC) $(CFLAGS) $(rundefs) -o $@ $(SRC)
	./$@
endif

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

.phony: clean FORCE
