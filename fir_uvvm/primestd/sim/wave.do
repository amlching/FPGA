quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /fir_tb/test_harness/clk
add wave -noupdate -label data_input_ready /fir_tb/test_harness/dut/data_input_ready
add wave -noupdate -label data_output_valid /fir_tb/test_harness/dut/data_output_valid
add wave -noupdate -label data_output_startofpacket /fir_tb/test_harness/dut/data_output_startofpacket
add wave -noupdate -label data_output_endofpacket /fir_tb/test_harness/dut/data_output_endofpacket
add wave -noupdate -label output_wave /fir_tb/test_harness/dut/data_output_data
add wave -noupdate -label control_state /fir_tb/test_harness/dut/control_state

add wave -noupdate -radix decimal -format analog-step -height 74 -max 66 -min -66 -label fir_data_in /fir_tb/test_harness/dut/fir_data_in
add wave -noupdate -radix decimal -format analog-step -height 74 -max 3e+06 -min -3e+06 -label fir_data_out /fir_tb/test_harness/dut/fir_data_out

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {339 ns}
