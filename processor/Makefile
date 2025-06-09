DESIGN	= sail
GB3_ROOT = /gb3-resources
LOG = output

sail-nextpnr:
	mkdir -p $(GB3_ROOT)/build
	cp programs/data.hex verilog/
	cp programs/program.hex verilog/
	yosys -q $(GB3_ROOT)/processor/yscripts/$(DESIGN).ys 2>&1 | tee $(GB3_ROOT)/processor/timing/$(LOG).txt
	nextpnr-ice40 --up5k --package uwg30 --json $(DESIGN).json --pcf pcf/$(DESIGN).pcf --asc $(DESIGN).asc 2>&1 | tee -a $(GB3_ROOT)/processor/timing/$(LOG).txt
	icetime -p pcf/sail.pcf -P uwg30 -d up5k -t sail.asc 2>&1 | tee -a $(GB3_ROOT)/processor/timing/$(LOG).txt
	icepack $(DESIGN).asc design.bin
	cp design.bin $(GB3_ROOT)/build/

clean:
	rm -f *.json *.blif *.asc *.bin
	rm -f programs/*.hex
	rm -f verilog/*.hex


###############################################################################
#  ───  RTL simulation with Cocotb (Icarus)  ──────────────────────────────── #
###############################################################################
# --------  Cocotb/Icarus self test  --------
###############################################################################
#  Cocotb self-test target
###############################################################################
PROJ_ROOT       := $(shell pwd)            # absolute path to repo
TOPLEVEL        := toplevel                   # module name in toplevel.v
TOPLEVEL_LANG   := verilog

# all HDL (no tb.v!)
VERILOG_SOURCES := toplevel.v $(wildcard verilog/*.v)

# compile flags for Icarus
IVERILOG_ARGS  := IVERILOG_ARGS = -DSIMULATION -DCOCOTB_SIM \
                -I $(shell pwd)/include \
                -I $(shell pwd)/sail-core/include


MODULE          := test_rv32i_benchmark       # python test – without “.py”
SIM             := icarus                     # backend
SIM_ARGS        := IVERILOG_ARGS="$(IVERILOG_ARGS)"

.PHONY: sim
sim:
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim \
	        TOPLEVEL=$(TOPLEVEL) TOPLEVEL_LANG=$(TOPLEVEL_LANG) \
	        VERILOG_SOURCES="$(VERILOG_SOURCES)"                \
	        MODULE=$(MODULE)                                    \
	        SIM=$(SIM) $(SIM_ARGS)