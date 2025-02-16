//----------------------------------------------------------------------------------------------------------------------
//! @file
//! @brief The top level unit converts fir avalon-st to axi-st.
//!
//----------------------------------------------------------------------------------------------------------------------
`timescale 1ns/10ps

//! @brief the entity provides the interfaces and generics required by avalon-st
module fir_top	#(
		parameter integer FACTOR = 2,
		parameter integer C_S_AXIS_TDATA_WIDTH	= 16,
		parameter integer C_S_AXIS_RDATA_WIDTH	= 16
	)
	(
		// AXI4Stream Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire S_AXIS_TREADY,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1:0] S_AXIS_TDATA,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID,

		// Ready to accept data out
		input wire  S_AXIS_RREADY,
		// Data out
		output reg [C_S_AXIS_RDATA_WIDTH-1:0] S_AXIS_RDATA,
		// Indicates boundary of last packet
		output reg  S_AXIS_RLAST,
		// Data is output valid
		output reg  S_AXIS_RVALID
	);	

	wire data_input_ready_int;
	wire data_input_valid_int;
	wire data_input_sop_int;
	wire data_input_eop_int;
	wire [C_S_AXIS_TDATA_WIDTH-1:0]data_input_data_int;
	
	wire data_output_ready_int;
	wire data_output_valid_int;
	wire data_output_sop_int;
	wire data_output_eop_int;
	wire [C_S_AXIS_RDATA_WIDTH-1:0]data_output_data_int;
	
	// axi-st transmit to avalon-st, todo, fill FIFO RAM with BIST vectors
	axi2avl axi2avl1(.S_AXIS_ACLK(S_AXIS_ACLK), .S_AXIS_ARESETN(S_AXIS_ARESETN), .S_AXIS_TREADY(S_AXIS_TREADY), .S_AXIS_TDATA(S_AXIS_TDATA),
	.S_AXIS_TLAST(S_AXIS_TLAST), .S_AXIS_TVALID(S_AXIS_TVALID), .DATA_INPUT_READY(data_input_ready_int), .DATA_INPUT_VALID(data_input_valid_int), 
	.DATA_INPUT_STARTOFPACKET(data_input_sop_int), .DATA_INPUT_ENDOFPACKET(data_input_eop_int), .DATA_INPUT_DATA(data_input_data_int));
	
	// fir with avalon-st interface
	fir_avl fir_avl1(.clk(S_AXIS_ACLK), .reset_n(S_AXIS_ARESETN), .data_input_ready(data_input_ready_int), .data_input_valid(data_input_valid_int),
	.data_input_startofpacket(data_input_sop_int), .data_input_endofpacket(data_input_eop_int), .data_input_data(data_input_data_int), 
	.data_output_ready(data_output_ready_int), .data_output_valid(data_output_valid_int), .data_output_startofpacket(data_output_sop_int), 
	.data_output_endofpacket(data_output_eop_int), .data_output_data(data_output_data_int));

	// axi-st receive from avalon-st, todo, add logic to check BIST vectors
	avl2axi avl2axi1(.S_AXIS_ACLK(S_AXIS_ACLK), .S_AXIS_ARESETN(S_AXIS_ARESETN), .S_AXIS_RREADY(S_AXIS_RREADY), .S_AXIS_RDATA(S_AXIS_RDATA),
	.S_AXIS_TLAST(S_AXIS_RLAST), .S_AXIS_RVALID(S_AXIS_RVALID), .DATA_OUTPUT_READY(data_output_ready_int), .DATA_OUTPUT_VALID(data_output_valid_int), 
	.DATA_OUTPUT_STARTOFPACKET(data_output_sop_int), .DATA_OUTPUT_ENDOFPACKET(data_output_eop_int), .DATA_OUTPUT_DATA(data_output_data_int));

endmodule
