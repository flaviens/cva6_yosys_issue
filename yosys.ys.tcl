if { [info exists ::env(VERILOG_INPUT)] }    { set VERILOG_INPUT $::env(VERILOG_INPUT) }       else { puts "Please set VERILOG_INPUT environment variable"; exit 1 }
if { [info exists ::env(VERILOG_OUTPUT)] }   { set VERILOG_OUTPUT $::env(VERILOG_OUTPUT) }     else { puts "Please set VERILOG_OUTPUT environment variable"; exit 1 }
if { [info exists ::env(TOP_MODULE)] }       { set TOP_MODULE $::env(TOP_MODULE) }             else { puts "Please set TOP_MODULE environment variable"; exit 1 }

yosys read_verilog -defer -sv $VERILOG_INPUT
yosys hierarchy -top $TOP_MODULE -check
yosys proc
yosys opt -purge

yosys write_verilog -sv -noattr $VERILOG_OUTPUT
