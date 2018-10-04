TARGET = sample

SRCS = $(wildcard *.v)

POF = output_files/$(TARGET).pof
SOF = output_files/$(TARGET).sof
SVF = output_files/$(TARGET).svf

.SUFFIXES:
.SUFFIXES: .pof .svf

# generate SVF file for JTAG programming at 3.3V, 1MHz
.pof.svf:
	quartus_cpf -c -q 1MHz -g 3.3 -n p $< $@

all:
	@echo "Type: make (compile|program|svf|clean)"

compile: $(POF)

# compile the design, using the setup in init.tcl
$(POF) $(SOF): $(SRCS) init.tcl
	quartus_sh -t init.tcl
	quartus_sh --flow compile $(TARGET)

# program SOF over JTAG to 1st device in the chain, using the 1st cable
program: $(SOF)
#	quartus_pgm -z -c 1 -m JTAG $(TARGET).cdf
	quartus_pgm -z -c 1 -m JTAG -o "p;$(SOF)@1"

svf: $(SVF)

clean:
	$(RM) *.qpf *.qsf *.rpt
	$(RM) *.bak *.old *~
	$(RM) -r output_files

cleaner: clean
	$(RM) -r db incremental_db

jtagd:
	jtagd --foreground --debug --user-start --config $$HOME/.jtagd.conf
