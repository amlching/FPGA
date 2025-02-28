# create work library
vlib work
set DV_DIR ./dv/

# compile RTL and UVM files
vlog $DV_DIR/tb/top.sv

#set StdArithNoWarnings 1
#set NumericStdNoWarnings 1

vsim -c top +UVM_CONFIG_DB_TRACE +UVM_NO_RELNOTES +UVM_TESTNAME=basic_test -voptargs=+acc=npr 
do wave.do

run -all 
#rm -rf work/ transcript *.txt *.vcd
#clear



