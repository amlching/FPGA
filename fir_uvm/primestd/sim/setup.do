# create work library
vlib work

# compile option
#

# compile uvm libraries

# compile source files
vlog -work work -stats=none ../rtl/fir_lowpass.sv
vlog -work work -stats=none ../rtl/fir_avl.sv
vlog -work work -stats=none ../rtl/axi2avl.sv
vlog -work work -stats=none ../rtl/avl2axi.sv
vlog -work work -stats=none ../rtl/fir_top.sv

# compile helper package

# compile testbench

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

#vlog -work work -stats=none $RTL_DIR/fir_tb.sv
#vsim -c -L work work.fir_tb -t ps +UVM_NO_RELNOTES +UVM_VERBOSITY=UVM_LOW -l run.log

#do wave.do
#run -all

