all: bootrom.hex program.hex
	make -C ../../rtl xtop

# build symbol dictionary
xdict.txt: 
	make -C ../../rtl xdict
	cp ../../rtl/xdict.txt .

# compile bootrom
bootrom.hex: bootrom.va xdict.txt
	../../tools/va -b < bootrom.va
	cp $@ ../../rtl

# compile 
program.hex: program.va xdict.txt
	../../tools/va < program.va
	cp $@ ../../rtl

clean:
	make -C ../../rtl clean
	@rm -f  xdict.txt *# *~ *.hex xrom.v


.phony: all clean
