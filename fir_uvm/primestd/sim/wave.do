add wave -noupdate -label clk /top/FIR_DUT/CLK
add wave -noupdate -label RESET /top/FIR_DUT/RESET
add wave -noupdate -radix decimal -format analog-step -height 74 -max 66 -min -66 -label fir_data_in /top/FIR_DUT/data_input_data_int
add wave -noupdate -label data_input_eop /top/FIR_DUT/data_input_eop_int
add wave -noupdate -label data_input_ready /top/FIR_DUT/data_input_ready_int
add wave -noupdate -label data_input_sop /top/FIR_DUT/data_input_sop_int
add wave -noupdate -label data_input_valid /top/FIR_DUT/data_input_valid_int
add wave -noupdate -radix decimal -format analog-step -height 74 -max 28627 -min -12002 -label fir_data_out /top/FIR_DUT/data_output_data_int
add wave -noupdate -label data_output_eop /top/FIR_DUT/data_output_eop_int
add wave -noupdate -label data_output_ready /top/FIR_DUT/data_output_ready_int
add wave -noupdate -label data_output_sop /top/FIR_DUT/data_output_sop_int
add wave -noupdate -label data_output_valid /top/FIR_DUT/data_output_valid_int
add wave -noupdate -label M_AXIS_TDATA /top/FIR_DUT/M_AXIS_TDATA
add wave -noupdate -label M_AXIS_TLAST /top/FIR_DUT/M_AXIS_TLAST
add wave -noupdate -label M_AXIS_TREADY /top/FIR_DUT/M_AXIS_TREADY
add wave -noupdate -label M_AXIS_TVALID /top/FIR_DUT/M_AXIS_TVALID
add wave -noupdate -label S_AXIS_TDATA /top/FIR_DUT/S_AXIS_TDATA
add wave -noupdate -label S_AXIS_TLAST /top/FIR_DUT/S_AXIS_TLAST
add wave -noupdate -label S_AXIS_TREADY /top/FIR_DUT/S_AXIS_TREADY
add wave -noupdate -label S_AXIS_TVALID /top/FIR_DUT/S_AXIS_TVALID

add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_add_st1
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_add_st2
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_add_st3
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_add_st4
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_add_st5
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_data
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_decimation_count
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_input_enable
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_input_valid_count
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_mult
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_output_valid_count
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/r_source_valid
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/reset_n
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/sink_data
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/sink_error
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/sink_valid
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/source_data
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/source_error
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/source_valid
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/f1/w_coeff


add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/currState
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_input_data
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_input_endofpacket
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_input_ready
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_input_ready_int
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_input_startofpacket
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_input_valid
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_data
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_data_int
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_endofpacket
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_endofpacket_int
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_ready
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_startofpacket
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_startofpacket_int
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_valid
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/data_output_valid_int
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/DATA_WIDTH
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/error_word
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/FACTOR
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/fir_data_in
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/fir_data_out
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/fir_data_out_valid
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/fir_error_out
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/fir_valid_in
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/header_part
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/length_in_count
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/length_out_count
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/nextState
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/reset
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/reset_fir_n
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/SCAN_COUNT_FIRST_PART
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/SCAN_COUNT_SECOND_PART
add wave -noupdate  sim:/top/FIR_DUT/fir_avl1/SENSOR_TYPE_FIRST_PART

add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/axis_tready
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/bit_num
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/DATA_INPUT_DATA
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/DATA_INPUT_ENDOFPACKET
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/DATA_INPUT_READY
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/DATA_INPUT_STARTOFPACKET
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/DATA_INPUT_VALID
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/fifo_wren
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/IDLE
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/mst_exec_state
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/read_pointer
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/reads_done
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/S_AXIS_ACLK
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/S_AXIS_ARESETN
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/S_AXIS_TDATA
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/S_AXIS_TLAST
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/S_AXIS_TREADY
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/S_AXIS_TVALID
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/stream_data_fifo
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/WRITE_FIFO
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/write_pointer
add wave -noupdate  sim:/top/FIR_DUT/axi2avl1/writes_done

add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/avl_output_ready
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/bit_num
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/DATA_OUTPUT_DATA
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/DATA_OUTPUT_ENDOFPACKET
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/DATA_OUTPUT_READY
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/DATA_OUTPUT_STARTOFPACKET
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/DATA_OUTPUT_VALID
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/fifo_wren
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/IDLE
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/M_AXIS_ACLK
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/M_AXIS_ARESETN
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/M_AXIS_TDATA
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/M_AXIS_TLAST
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/M_AXIS_TREADY
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/M_AXIS_TVALID
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/mst_exec_state
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/NUM_OF_SAMPLES
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/NUMBER_OF_OUTPUT_WORDS
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/read_pointer
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/reads_done
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/stream_data_fifo
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/WRITE_FIFO
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/write_pointer
add wave  -noupdate  sim:/top/FIR_DUT/avl2axi1/writes_done