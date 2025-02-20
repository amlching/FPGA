//----------------------------------------------------------------------------------------------------------------------
//! @file
//! @brief The top level unit converts fir avalon-st to axi-st.
//!
//----------------------------------------------------------------------------------------------------------------------
`timescale 1ns/10ps
`define DATA_WIDTH 16
`define FACTOR 2

//! @brief the entity provides the interfaces and generics required by avalon-st
module fir_top	#(
		parameter integer FACTOR = 2,
		parameter integer DATA_WIDTH = 16,
		parameter integer NUM_OF_SAMPLES = 2000
	)
	(
		// AXI4Stream Clock
		input wire  CLK,
		// AXI4Stream Reset
		input wire  RESET,
		// Ready to accept data in
		output wire S_AXIS_TREADY,
		// Data in
		input wire [DATA_WIDTH-1:0] S_AXIS_TDATA,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID,

		// Ready to accept data out
		input wire  M_AXIS_TREADY,
		// Data out
		output reg [DATA_WIDTH-1:0] M_AXIS_TDATA,
		// Indicates boundary of last packet
		output reg  M_AXIS_TLAST,
		// Data is output valid
		output reg  M_AXIS_TVALID
	);	

	wire data_input_ready_int;
	wire data_input_valid_int;
	wire data_input_sop_int;
	wire data_input_eop_int;
	wire [DATA_WIDTH-1:0]data_input_data_int;
	
	wire data_output_ready_int;
	wire data_output_valid_int;
	wire data_output_sop_int;
	wire data_output_eop_int;
	wire [DATA_WIDTH-1:0]data_output_data_int;
	
	wire axi_reset_n = ~RESET;
	
	// axi-st transmit to avalon-st, todo, fill FIFO RAM with BIST vectors
	axi2avl #(`DATA_WIDTH, `NUM_OF_SAMPLES) axi2avl1(.S_AXIS_ACLK(CLK), .S_AXIS_ARESETN(axi_reset_n), .S_AXIS_TREADY(S_AXIS_TREADY), .S_AXIS_TDATA(S_AXIS_TDATA),
	.S_AXIS_TLAST(S_AXIS_TLAST), .S_AXIS_TVALID(S_AXIS_TVALID), .DATA_INPUT_READY(data_input_ready_int), .DATA_INPUT_VALID(data_input_valid_int), 
	.DATA_INPUT_STARTOFPACKET(data_input_sop_int), .DATA_INPUT_ENDOFPACKET(data_input_eop_int), .DATA_INPUT_DATA(data_input_data_int));
	
	// fir with avalon-st interface
	fir_avl #(`FACTOR,`DATA_WIDTH) fir_avl1(.clk(CLK), .reset(RESET), .data_input_ready(data_input_ready_int), .data_input_valid(data_input_valid_int),
	.data_input_startofpacket(data_input_sop_int), .data_input_endofpacket(data_input_eop_int), .data_input_data(data_input_data_int), 
	.data_output_ready(data_output_ready_int), .data_output_valid(data_output_valid_int), .data_output_startofpacket(data_output_sop_int), 
	.data_output_endofpacket(data_output_eop_int), .data_output_data(data_output_data_int));

	// axi-st receive from avalon-st, todo, add logic to check BIST vectors
	avl2axi #(`FACTOR,`DATA_WIDTH, `NUM_OF_SAMPLES)  avl2axi1(.M_AXIS_ACLK(CLK), .M_AXIS_ARESETN(axi_reset_n), .M_AXIS_TREADY(M_AXIS_TREADY), .M_AXIS_TDATA(M_AXIS_TDATA),
	.M_AXIS_TLAST(M_AXIS_TLAST), .M_AXIS_TVALID(M_AXIS_TVALID), .DATA_OUTPUT_READY(data_output_ready_int), .DATA_OUTPUT_VALID(data_output_valid_int), 
	.DATA_OUTPUT_STARTOFPACKET(data_output_sop_int), .DATA_OUTPUT_ENDOFPACKET(data_output_eop_int), .DATA_OUTPUT_DATA(data_output_data_int));

endmodule
