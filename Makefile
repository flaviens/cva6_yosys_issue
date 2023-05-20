WFLAGS=-Wno-PINCONNECTEMPTY -Wno-fatal -Wno-BLKANDNBLK -Wno-DECLFILENAME -Wno-PINMISSING -Wno-WIDTH -Wno-SELRANGE -Wno-WIDTHCONCAT -Wno-VARHIDDEN -Wno-LATCH -Wno-SYMRSVDWORD -Wno-CASEINCOMPLETE -Wno-UNSIGNED -Wno-UNDRIVEN -Wno-UNUSEDPARAM -Wno-UNUSEDSIGNAL -Wno-ALWCOMBORDER -Wno-IMPORTSTAR -Wno-ENUMVALUE -Wno-LITENDIAN -Wno-UNOPTFLAT -Wno-SYNCASYNCNET -Wno-BLKSEQ -Wno-UNPACKED -Wno-SELRANGE -Wno-CASEOVERLAP
VERILOG_SRC=ariane_pickled.sv
TOP_MODULE=ariane_tiny_soc
SIMSRAMELF=app.elf


run_vanilla: generated/vanilla/Variane_tiny_soc
	SIMSRAMELF=$(SIMSRAMELF) ./generated/vanilla/Variane_tiny_soc

run_instrumented: generated/instrumented/Variane_tiny_soc
	SIMSRAMELF=$(SIMSRAMELF) ./generated/instrumented/Variane_tiny_soc


generated/sv2v_out.v: $(VERILOG_SRC) | generated
	sv2v -E=UnbasedUnsized -DSYNTHESIS -DVERILATOR $< > $@

generated/yosys_output.sv: generated/sv2v_out.v | generated
	TOP_MODULE=ariane_mem_top VERILOG_INPUT=$< VERILOG_OUTPUT=$@ yosys -c yosys.ys.tcl


generated/vanilla/Variane_tiny_soc: ariane_tiny_soc.sv ariane_pickled.sv mem.sv | generated
	verilator $(WFLAGS) --top $(TOP_MODULE) --trace --binary $^ ../../toplevel.cc ../../elfloader.cc -I../../ -Mdir generated/vanilla -j 60 -CFLAGS '-DVCD_FILEPATH=\"trace_vanilla.vcd\"'

generated/instrumented/Variane_tiny_soc: ariane_tiny_soc.sv generated/yosys_output.sv mem.sv | generated
	verilator $(WFLAGS) --top $(TOP_MODULE) --trace --binary $^ ../../toplevel.cc ../../elfloader.cc -I../../ -Mdir generated/instrumented -j 60 -CFLAGS '-DVCD_FILEPATH=\"trace_instrumented.vcd\"'


generated generated/vanilla generated/instrumented:
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf generated

