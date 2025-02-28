`timescale 1ns/10ps
// insipred by myipp_v1_0_S00_AXIS generated by AMD's Vivado'create custom IP code
module axi2avl #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// AXI4Stream sink: Data Width
		parameter integer DATA_WIDTH	= 16,
		parameter integer NUM_OF_SAMPLES = 2000
	)
	(
		// Avalon st rx port
		//! indicates that the unit accepts transactions
		input wire DATA_INPUT_READY,					
		//! indicates that the incoming Avalon-ST transaction is valid
		output reg DATA_INPUT_VALID,							
		//! indicates whether an incoming Avalon-ST packet starts
		output reg DATA_INPUT_STARTOFPACKET,					
		//! indicates whether an incoming Avalon-ST packet ends
		output reg DATA_INPUT_ENDOFPACKET,					
		//! the incoming Avalon-ST data, including peak/average flag
		output reg [DATA_WIDTH-1:0] DATA_INPUT_DATA,			

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire S_AXIS_TREADY,
		// Data in
		input wire [DATA_WIDTH-1:0] S_AXIS_TDATA,
		// Indicates boundary of last packet (optional)
		input wire  S_AXIS_TLAST, 
		// Data is in valid
		input wire  S_AXIS_TVALID
	);
	// function called clogb2 that returns an integer which has the 
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

	// Total number of input data.	  NUM_OF_SAMPLES samples + 4 header/footer
	localparam NUMBER_OF_INPUT_WORDS  = NUM_OF_SAMPLES+4;
	// bit_num gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size of FIFO.
	localparam bit_num  = clogb2(NUMBER_OF_INPUT_WORDS-1);
	// Define the states of state machine
	// The control state machine oversees the writing of input streaming data to the FIFO,
	// and outputs the streaming data from the FIFO
	parameter [1:0] IDLE = 1'b0,        // This is the initial/idle state 

	                WRITE_FIFO  = 1'b1; // In this state FIFO is written with the
	                                    // input stream data S_AXIS_TDATA 
	// Triggers start of read FIFO
	wire fifo_almost_full;
	// Triggers start of write FIFO
	wire axis_tready;
	// State variable
	reg mst_exec_state;     
	// FIFO write enable
	wire fifo_wren;
	// FIFO write pointer
	reg [bit_num-1:0] write_pointer;
	// sink has accepted all the streaming data and stored in FIFO
	reg writes_done;
	// FIFO read pointer
	reg [bit_num-1:0] read_pointer;
	// sink has emptied all the streaming data and from FIFO
	reg reads_done;
	
	assign S_AXIS_TREADY	= axis_tready;
	// Control state machine implementation
	always @(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN) 
	begin  
	  if (!S_AXIS_ARESETN) 
	  // asynchronous reset (active low)
	    begin
	      mst_exec_state <= IDLE;
	    end  
	  else
	    case (mst_exec_state)
	      IDLE: 
	        // The sink starts accepting tdata when 
	        // there tvalid is asserted to mark the
	        // presence of valid streaming data 
	          if (S_AXIS_TVALID)
	            begin
	              mst_exec_state <= WRITE_FIFO;
	            end
	          else
	            begin
	              mst_exec_state <= IDLE;
	            end
	      WRITE_FIFO: 
	        // When the sink has accepted all the streaming input data,
	        // the interface swiches functionality to a streaming master
	        if (writes_done)
	          begin
	            mst_exec_state <= IDLE;
	          end
	        else
	          begin
	            // The sink accepts and stores tdata 
	            // into FIFO
	            mst_exec_state <= WRITE_FIFO;
	          end

	    endcase
	end
	// AXI Streaming Sink 
	// 
	// The example design sink is always ready to accept the S_AXIS_TDATA  until
	// the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
	assign axis_tready = (((mst_exec_state == WRITE_FIFO) && (write_pointer <= NUMBER_OF_INPUT_WORDS-1)) && !read_pointer); // don't overwrite when reading
	
	// almost full flag as a pulse to trigger read, read is two times faster than write
//	assign fifo_almost_full = (write_pointer == NUMBER_OF_INPUT_WORDS/2);
	assign fifo_almost_full = (write_pointer == NUMBER_OF_INPUT_WORDS-1); // read when write is done
	
	always@(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN)
	begin
	  if(!S_AXIS_ARESETN)
	    begin
	      write_pointer <= 0;
	      writes_done <= '0;
	    end  
	  else
	    if (write_pointer <= NUMBER_OF_INPUT_WORDS-1)
	      begin	  
			if (fifo_wren)
	          begin
				if (write_pointer == NUMBER_OF_INPUT_WORDS-1) //|| S_AXIS_TLAST)
				begin
	              // reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
	              // has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
				  writes_done <= '1;
				  write_pointer <= 0;
				end	
				else begin
	              // write pointer is incremented after every write to the FIFO
	              // when FIFO write signal is enabled.
	              write_pointer <= write_pointer + 1;
				  writes_done <= '0;
				end	
	          end
	      end  
	end

	// FIFO write enable generation
	assign fifo_wren = S_AXIS_TVALID && axis_tready;

	// FIFO Implementation in FF's, infer FIFO in future
	reg  [DATA_WIDTH-1:0] stream_data_fifo [0 : NUMBER_OF_INPUT_WORDS-1];

	// Streaming input data is stored in FIFO
	always @( posedge S_AXIS_ACLK )
    begin
        if (fifo_wren)
            stream_data_fifo[write_pointer] <= S_AXIS_TDATA;
	end		

	// Hook up avalon-st rx signals
	//! DATA_INPUT_READY indicates that the unit accepts transactions to read FIFO
	always@(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN)
	begin
	  if(!S_AXIS_ARESETN)
	    begin
	      read_pointer <= 0;
		  reads_done <= '0;
		  DATA_INPUT_VALID <= '0;
		  DATA_INPUT_STARTOFPACKET <= '0;		  
		  DATA_INPUT_ENDOFPACKET <= '0;
	    end  
	  else if (read_pointer < NUMBER_OF_INPUT_WORDS-1)
	    begin
		  DATA_INPUT_ENDOFPACKET <= '0;
		  reads_done <= '0;
		  if (fifo_almost_full)
			begin
			  read_pointer <= 0;		  
			  // read is faster than write, if start of frame starts before write ends it has to stall but fir_avl cannot stall
			  DATA_INPUT_VALID <= '1; 				  
			  DATA_INPUT_STARTOFPACKET <= '1;
			end
		  if (DATA_INPUT_READY && !reads_done)
	        begin
	          // read pointer is incremented after every read from the FIFO
	          // when DATA_INPUT_READY signal is enabled.
	          read_pointer <= read_pointer + 1;
			  DATA_INPUT_STARTOFPACKET <= '0;
			  DATA_INPUT_ENDOFPACKET <= '0;			
	        end		  
		end  	
	  else if (read_pointer == NUMBER_OF_INPUT_WORDS-1) // all data regardless
		begin
		  // reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
		  // has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
		  reads_done <= '1;
		  DATA_INPUT_ENDOFPACKET <= '1;
		  DATA_INPUT_VALID <= '0;
		  read_pointer <= 0;
		end		
	end

	assign DATA_INPUT_DATA = stream_data_fifo[read_pointer];

	endmodule