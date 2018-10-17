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
	cp $@ ../../xilinx/14.7/picoversat

# compile 
program.hex: program.va xdict.txt
	../../tools/va < program.va
	cp $@ ../../rtl
	cp $@ ../../rtl 
	cp $@ ../../xilinx/14.7/picoversat

clean:
	make -C ../../rtl clean
	@rm -f  xdict.txt *# *~ *.hex rom.v
	@rm ../../xilinx/14.7/picoversat/*.hex


.phony: all clean
