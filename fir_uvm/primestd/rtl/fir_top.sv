//----------------------------------------------------------------------------------------------------------------------
//! @file
//! @brief The unit applies low pass filter and sends output data to avalon-st.
//!
//----------------------------------------------------------------------------------------------------------------------
`timescale 1ns/10ps

//! @brief the entity provides the interfaces and generics required by avalon-st
module fir_top(clk, reset, data_input_ready, data_input_valid, data_input_startofpacket, data_input_endofpacket, data_input_data, 
data_output_ready, data_output_valid, data_output_startofpacket, data_output_endofpacket, data_output_data);

//! @details the unit does not handle back-pressure and stalls on the input and output Avalon-ST interfaces.
//! The various processes form a logical pipeline as shown in the main page of the documentation.

	parameter DATA_WIDTH = 16; 					//! Width of filter data
	parameter FACTOR = 2;						//! 1 means no decimation

	input clk;									//! clock 					
	input reset;								//! reset, active high

	output data_input_ready;					//! indicates that the unit accepts transactions
	input data_input_valid;						//! indicates that the incoming Avalon-ST transaction is valid
	input data_input_startofpacket;				//! indicates whether an incoming Avalon-ST packet starts
	input data_input_endofpacket;				//! indicates whether an incoming Avalon-ST packet ends
	input [DATA_WIDTH-1:0] data_input_data;		//! the incoming Avalon-ST data, including peak/average flag
	
	input data_output_ready;					//! indicates if the connected Avalon-ST sink interface accepts data
	output data_output_valid;					//! the transaction is valid
	output data_output_startofpacket;			//! signals a sink that a new packet will be sent
	output data_output_endofpacket;				//! signals the end of a packet
	output [DATA_WIDTH-1:0] data_output_data;	//! transaction data

	typedef enum logic[3:0] {control_idle = 4'b0001,
                         forward_header = 4'b0010,
                         proc_fir_data = 4'b0100,
                         wait_fir_end = 4'b1000} states_onehot_t; 
	states_onehot_t currState = control_idle;
	states_onehot_t nextState;
	
	int i_header_part;
	int SENSOR_TYPE_FIRST_PART = 0;
	int SCAN_COUNT_FIRST_PART = 1;
	int SCAN_COUNT_SECOND_PART = 2;
	int i_length_in_count;
	int i_length_out_count;

	logic [DATA_WIDTH-1:0]error_word;
	logic reset_fir_n;
	logic [DATA_WIDTH-1:0]fir_data_in;
	logic fir_valid_in;
	logic [32:0]fir_data_out;
	logic [1:0]fir_error_out;
	logic fir_data_out_valid;
	
	logic data_input_ready_int;
	reg	r_data_input_ready;
	logic data_output_valid_int;
	reg r_data_output_valid;
	logic data_output_startofpacket_int;
	reg r_data_output_startofpacket;
	logic data_output_endofpacket_int;
	reg r_data_output_endofpacket;
	logic data_output_data_int;
	reg r_data_output_data;
	
	// register output signals
	always_ff @ (posedge clk or posedge reset)
		if (reset) begin
			r_data_input_ready 			<= '0;
			r_data_output_valid 		<= '0;
			r_data_output_startofpacket <= '0;
			r_data_output_endofpacket 	<= '0;
			r_data_output_data 			<= '0;
		end else begin
			r_data_input_ready 			<= data_input_ready_int;
		    r_data_output_valid 		<= data_output_valid_int;
			r_data_output_startofpacket <= data_output_startofpacket_int;
			r_data_output_endofpacket 	<= data_output_endofpacket_int;
			r_data_output_data 			<= data_output_data_int;
		end
		
	// assign output signals
	assign data_input_ready 			= r_data_input_ready;
	assign data_output_valid 			= r_data_output_valid;
	assign data_output_startofpacket 	= r_data_output_startofpacket;
	assign data_output_endofpacket 		= r_data_output_endofpacket;
	assign data_output_data 			= r_data_output_data;
			
	// 21 taps, low pass filter coefficients are hardcoded
	fir_lowpass f1(.clk(clk), .reset_n(reset_fir_n), .sink_data(fir_data_in), .sink_valid(fir_valid_in), .sink_error('0),
					.source_data(fir_data_out), .source_valid(fir_data_out_valid), .source_error(fir_error_out));

	//! @anchor FSM
	//! @brief This is the main control process of fir_top unit.
	//! @details The control process checks if a new data packet is available. In this case it starts
	//! the forwards header. Afterwards, it processes FIR, 
	//! then forwards filtered output to dataset as per calculated length. 
	
	// current state
	always_ff @ (posedge clk or posedge reset)
		if (reset)
			currState <= control_idle;
		else
			currState <= nextState;
		
	// next state logic
	always_comb begin
		unique case (currState)
			control_idle: begin
				if (data_input_startofpacket & data_input_valid & data_output_ready) 
					nextState 		<= forward_header;
				else
					nextState 		<= control_idle;
			end
			forward_header: begin	  		    
				if (data_input_endofpacket)
					nextState       <= wait_fir_end;
				else if (i_header_part == SCAN_COUNT_SECOND_PART)
					nextState 		<= proc_fir_data;
			end
			proc_fir_data: begin	
				if (data_input_endofpacket)
					nextState       <= wait_fir_end;
			end
			wait_fir_end: begin	
				if (i_length_out_count >= (i_length_in_count/FACTOR))   		    
					nextState  		<= control_idle;
			end
		endcase
	end

	// FSM outputs
	always_comb begin
		unique case (currState)
			control_idle: begin
				if (data_input_startofpacket & data_input_valid & data_output_ready) 
					data_input_ready_int 		<= '1;
				else
					data_input_ready_int 		<= '0;
				i_header_part 					= SENSOR_TYPE_FIRST_PART;
				reset_fir_n 					<= '0;
				fir_valid_in 					<= '0;
				data_output_valid_int			<= '0;
				data_output_startofpacket_int 	<= '0;
				data_output_endofpacket_int   	<= '0;
				data_output_data_int          	<= '0;
				i_length_in_count 				= 0;
				i_length_out_count 				= 0;
				error_word						<= '0;
				fir_data_in						<= '0;				
			end
			forward_header: begin	
				reset_fir_n					<= '1;
				data_output_endofpacket_int <= '0;
				data_output_data_int 		<= data_input_data;

				case (i_header_part)
					SENSOR_TYPE_FIRST_PART: begin
						data_output_startofpacket_int	<= '1;
					end
					(SCAN_COUNT_FIRST_PART | SCAN_COUNT_SECOND_PART): begin
						data_output_startofpacket_int	<= '0;
					end
				endcase;  		    
				if (data_input_endofpacket) begin
					data_input_ready_int 	<= '0;
					data_output_valid_int	<= '0;
					error_word 				<= data_input_data;
					i_length_out_count 	= i_length_in_count/FACTOR;
				end else if (i_header_part == SCAN_COUNT_SECOND_PART)
					data_output_valid_int	<= '0;
				else begin
					data_input_ready_int 	<= '1;
					data_output_valid_int	<= '1;
				end
				if(i_header_part < SCAN_COUNT_SECOND_PART)
					i_header_part = i_header_part + 1;
			end	
			proc_fir_data: begin	
				fir_data_in <= data_input_data;
				// truncate 33rd sign bit and divide by Q16
				data_output_data_int 		<= fir_data_out[31:16]; // Q16
				data_output_valid_int 		<= fir_data_out_valid;  				
				if (data_input_endofpacket) begin
					data_input_ready_int 	<= '0;
					error_word				<= data_input_data;
					fir_valid_in 			<= '0;
				end else begin
					data_input_ready_int 	<= '1;
					fir_valid_in 			<= data_input_valid;
					if (data_input_valid)
						i_length_in_count = i_length_in_count + 1;			
				    if (fir_data_out_valid)
						i_length_out_count 	= i_length_out_count + 1;
				end
			end					
			wait_fir_end: begin	
				data_input_ready_int 			<= '0;
				if (i_length_out_count >= (i_length_in_count/FACTOR)) begin  		    
					// error bits
					data_output_data_int 		<= {error_word[13:0], fir_error_out};
					data_output_valid_int 		<= '1;
					data_output_endofpacket_int <= '1;
					reset_fir_n					<= '0;
					fir_data_in 				<= '0;
					fir_valid_in 				<= '0;
				end else begin
					if (fir_data_out_valid)
						i_length_out_count = i_length_out_count + 1;
					data_output_valid_int 	<= fir_data_out_valid;
					// truncate 33rd bit sign and divide by Q16
					data_output_data_int 	<= fir_data_out[31:16];
				end
			end	
		endcase
	end	
// todo, add BIST RAM and logic
endmodule
