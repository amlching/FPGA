//.......................................................
// Scoreboard
//.......................................................
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  rand	bit [`DATA_WIDTH-1:0] refq[`COUNT][$]; // temporary reference queue
  int scan_file    ; // file handler
  int rtn_code;
  int signed captured_data;
  int scan_count;
  int total_num_sample;
  int sample_number;
  int dummy;
  int packet_error;
  string line;
  bit signed [`DATA_WIDTH-1:0] expected;
  bit signed [`DATA_WIDTH-1:0] actual;
	
  uvm_analysis_imp #(axi4_slave_seq_item, scoreboard) m_analysis_imp;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function write(axi4_slave_seq_item item);
	//$display("entering scoreboard");
	scan_file = $fopen("generate_testdata/fir_data1.txt", "r");
	
	// Read first 10 packets from file
	for(int i=0;i<10;i=i+1) begin
	  packet_error = 0;
	  rtn_code = $fgets (line, scan_file); // read first line for "scan_count,total_num_sample,0"
	  rtn_code = $sscanf (line, "%d,%d,%d", scan_count, total_num_sample, dummy); // parse
	  //$display("scan count=%d, total_num_sample=%d",scan_count, total_num_sample);
	  refq[i].push_back('hAA); // sensor type 
	  refq[i].push_back(scan_count[15:0]); // scan count lower word
	  refq[i].push_back(scan_count>>16); // scan count upper word
      // load input samples from file			
	  for(int j=0;j<total_num_sample;j=j+1) begin 
		rtn_code = $fgets (line, scan_file); // contains "sample_number,captured_data"
		rtn_code = $sscanf (line, "%d,%d", sample_number, captured_data); // parse
		refq[i].push_back(signed'(16'(captured_data))); 
	  end
	  rtn_code = $fgets (line, scan_file); // last line "error_word"
	  rtn_code = $sscanf (line, "%d", captured_data); // parse	
	  refq[i].push_back(captured_data[15:0]);
	  // compare each packet content from 0 to 9
	  for(int k=0;k<total_num_sample;k=k+1) begin 
		expected = refq[i].pop_front(); // monitor missed catching the first packet, skip the first one for now
		actual = item.data[i].pop_front();
		if(actual != expected)
		  begin
            `uvm_error (get_type_name(), $sformatf("ERROR! Packet#%d, Word#%d mismatch, read=%d, expected=%d", i, k, actual, expected))
			packet_error = 1;
		  end
	  end
	  if(!packet_error)
        `uvm_info(get_type_name(), $sformatf("PASS! Packet #%d matches",i), UVM_LOW)			
	end
	//$display("leaving scoreboard");
	$fclose(scan_file);
  endfunction
endclass