/*MIT License

Copyright (c) 2021 makararasi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

class axi4_master_sanity_sequence extends uvm_sequence#(axi4_master_seq_item);

    `uvm_object_utils(axi4_master_sanity_sequence)
    axi4_master_seq_item req;
    process job1;
    int seq_count;
	//int Print_handle;
    int scan_file    ; // file handler
	int rtn_code;
	int signed captured_data;
	int scan_count;
	int total_num_sample;
	int sample_number;
	int dummy;
	string line;

    function new(string name = "axi4_master_sanity_sequence");
        super.new(name);
    endfunction
    
    //function void get_print(int a);
    //    this.Print_handle = a;
    //endfunction

    virtual task body();
		scan_file = $fopen("generate_testdata/stimulus_test1.txt", "r");
		req  = axi4_master_seq_item::type_id::create("req");
		// workaround that master driver missed the first item
		start_item(req);	
		finish_item(req);
        repeat(`COUNT)
        begin
            start_item(req);
			rtn_code = $fgets (line, scan_file); // read first line for "scan_count,total_num_sample"
            rtn_code = $sscanf (line, "%d,%d", scan_count, total_num_sample); // parse		
			req.size = total_num_sample+4; // total_num_sample + 4 header and footer
			req.data[0] = 'hAA; // sensor type
			req.tstrb[0] = '1;  // both bytes enabled
			req.data[1] = scan_count[15:0]; // scan count lower word
			req.tstrb[1] = '1;  // both bytes enabled
			req.data[2] = scan_count >> 16; // scan count upper word
			req.tstrb[2] = '1;  // both bytes enabled
			//req.sparse_continuous_aligned_en = 0; // 0-> continuous_aligned
			rtn_code = $fgets (line, scan_file); // skip two lines reserved for future
			rtn_code = $fgets (line, scan_file); // skip two lines reserved for future
            // load input samples from file			
			for(int i=3;i<total_num_sample+3;i=i+1) begin 
			  rtn_code = $fgets (line, scan_file); // contains "sample_number,captured_data"
              rtn_code = $sscanf (line, "%d,%d", sample_number, captured_data); // parse				  
			  req.data[i] = captured_data[15:0];
			  req.tstrb[i] = '1;  // both bytes enabled
			end
			rtn_code = $fgets (line, scan_file); // last line "0,0,error_word"
            rtn_code = $sscanf (line, "%d,%d,%d", dummy, dummy, captured_data); // parse			
			req.data[total_num_sample+3] = captured_data[15:0]; // incomming error word 
			req.tstrb[total_num_sample+3] = '1;  // both bytes enabled
			req.clk_count = 1; // buffer time
			finish_item(req);
            //Print_handle = $fopen("data_debug_dump.txt","ab"); 	 
			//$fdisplay(Print_handle,"|sequence_count\t",seq_count, "\t|time\t" ,$time,"|");
			//$display("loaded packet %d",seq_count);			
            //seq_count = seq_count + 1;
            //$fclose(Print_handle);
        end
		$fclose(scan_file);
    endtask
   
endclass : axi4_master_sanity_sequence



