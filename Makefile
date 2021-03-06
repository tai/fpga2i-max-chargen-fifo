# vendor tool path
PATH := /opt/altera/18.0/quartus/bin:$(PATH)
export PATH

# project and top-level entity name
PROJECT = sample
TARGET = top

# top-level entity name

# verilog code compiler
VCC = iverilog -g2005-sv -Wall -Wtimescale

# src (testbench and synthesizable code)
SRCS    = $(wildcard *.v)
SRCS_TB = $(wildcard *_tb.v)
SRCS_SY = $(filter-out $(SRCS_TB),$(SRCS))

TB = $(SRCS_TB:.v=)
SY = $(SRCS_SY:.v=)

POF = output_files/$(PROJECT).pof
SOF = output_files/$(PROJECT).sof
SVF = output_files/$(PROJECT).svf

.SUFFIXES:
.SUFFIXES: .pof .svf

# generate SVF file for JTAG programming at 3.3V, 1MHz
.pof.svf:
	quartus_cpf -c -q 1MHz -g 3.3 -n p $< $@

all:
	@echo "Type: make (test|check|compile|program|svf|clean)"

check: $(TARGET)

compile: check $(POF)

test: $(TB)
	for i in $(TB); do ./$$i | sed -e 's/\x0/_/g'; done | \
	awk 'BEGIN{rc=0} {print} /^NG:/{rc=1} END{exit(rc)}'

# compile the design, using the setup in init.tcl
$(POF) $(SOF): $(SRCS_SY) init.tcl
	quartus_sh -t init.tcl
	quartus_sh --flow compile $(PROJECT)

# program SOF over JTAG to 1st device in the chain, using the 1st cable
program: $(SOF)
#	quartus_pgm -z -c 1 -m JTAG $(PROJECT).cdf
	quartus_pgm -z -c 1 -m JTAG -o "p;$(SOF)@1"

svf: $(SVF)

clean:
# clean up quartus-generated files
	$(RM) -r output_files
	$(RM) *.qpf *.qsf *.qws *.rpt *.summary
# clean up iverilog-generated files
	$(RM) *.vcd *.E $(TARGET) $(TB)
# clean up other files
	$(RM) *.bak *.old *~

cleaner: clean
# clean up quartus-generated files
	$(RM) -r db incremental_db

jtagd:
	jtagd --foreground --debug --user-start --config $$HOME/.jtagd.conf

# top-level testbench depends on all synthesizable target code
$(TARGET)_tb: $(TARGET)_tb.v $(SRCS_SY)
	$(VCC) -s $@ -o $@ $^

$(TARGET): $(SRCS_SY)
	$(VCC) -s $@ -o $@ $^

# testbench depends on synthesizable target code
%_tb: %_tb.v %.v
	$(VCC) -s $@ -o $@ $^

%: %.v
	$(VCC) -s $@ -o $@ $^

%.E: %.v
	$(VCC) -E -s $@ -o $@ $^
