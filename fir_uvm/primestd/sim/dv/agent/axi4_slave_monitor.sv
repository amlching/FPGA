//.......................................................
// Monitor
//.......................................................
class axi4_slave_monitor extends uvm_monitor;
  `uvm_component_utils(axi4_slave_monitor)
  
  int word;		// word count
  int packet; 	// packet count
  
  function new(string name="axi4_slave_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  uvm_analysis_port  #(axi4_slave_seq_item) mon_analysis_port;
  virtual axi_intf#(`DATA_WIDTH) vif;
  semaphore sema4;	
	
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_intf#(`DATA_WIDTH))::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Could not get vif")  
    sema4 = new(1);
    mon_analysis_port = new ("mon_analysis_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // This task monitors the interface for a complete
    // transaction and writes into analysis port when complete
	begin
	axi4_slave_seq_item item = new;
    forever begin
	  @ (posedge vif.clk);
		if(vif.rst)
		  begin		  
			packet <= 0;
			word <= 0;
		  end 
		else if (vif.m_axis_tvalid && vif.m_axis_tready)
		  begin			  
			item.data[packet].push_back(vif.m_axis_tdata); // push in slave data
			word <= word + 1;
		  end
		if(vif.m_tlast)
		  begin	  
			`uvm_info(get_type_name(), $sformatf("Monitor found packet#%d with%d words", packet, word+1), UVM_LOW)		  
			packet <= packet + 1;
			word <= 0;			
			if(packet == 7) begin			  
			  mon_analysis_port.write(item); // write 8 slave packets to scordboard to compare
			end	  
		  end
    end
	end
  endtask
endclass : axi4_slave_monitor	 