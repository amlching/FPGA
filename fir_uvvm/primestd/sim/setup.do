# create work library
vlib work

# compile option
set USER_DEFINED_VHDL_COMPILE_OPTIONS "-2008"

# compile uvvm libraries
do ../../../common/uvvm/uvvm_util/script/compile_src.do ../../../common/uvvm/uvvm_util
do ../../../common/uvvm/uvvm_vvc_framework/script/compile_src.do ../../../common/uvvm/uvvm_vvc_framework
do ../../../common/uvvm/bitvis_vip_avalon_st/script/compile_src.do ../../../common/uvvm/bitvis_vip_avalon_st

# compile source files
vcom -work work -2008 -explicit -stats=none ../hdl/fir_lowpass.vhd
vcom -work work -2008 -explicit -stats=none ../hdl/fir_top.vhd

# compile helper package
vcom -work work -2008 -explicit -stats=none ./fir_sim_helper_pkg.vhd

# compile testbench
vcom -work work -2008 -explicit -stats=none ./fir_th.vhd
vcom -work work -2008 -explicit -stats=none ./fir_tb.vhd

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

vsim -c -L work work.fir_tb -t ps 
do wave.do
run -all

