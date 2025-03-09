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
`define DATA_WIDTH 16
`define FACTOR 2
`define COUNT 10
`define NUM_OF_SAMPLES 500 
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "./../env/axi_intf.sv"
`include "./../sequence/axi4_master_seq_item.sv"
`include "./../sequence/axi4_slave_seq_item.sv"
`include "./../agent/axi4_master_driver.sv"
`include "./../agent/axi4_slave_driver.sv"
`include "./../sequence/axi4_seqr.sv"
`include "./../agent/axi4_master_agent.sv"
`include "./../agent/axi4_slave_monitor.sv"
`include "./../agent/axi4_slave_agent.sv"
`include "./../env/scoreboard.sv"
`include "./../env/axi4_env.sv"
`include "./../sequence/axi4_master_sequence.sv"
`include "./../sequence/axi4_slave_sequence.sv"
`include "./../env/axi4_test.sv"


// rtl files
`include "./../rtl/fir_lowpass.sv"
`include "./../rtl/fir_avl.sv"
`include "./../rtl/axi2avl.sv"
`include "./../rtl/avl2axi.sv"
`include "./../rtl/fir_top.sv"

module top ;


    bit clk,rst;
    axi_intf#(`DATA_WIDTH) inf(clk,rst);

/*----------------DUT_INSTANCE_START------------------*/
   
    fir_top #(`FACTOR,`DATA_WIDTH,`NUM_OF_SAMPLES) FIR_DUT( .CLK(inf.clk),
                                    .RESET(inf.rst),
                                    .S_AXIS_TDATA (inf.s_axis_tdata) ,
                                    .S_AXIS_TVALID(inf.s_axis_tvalid),
                                    .S_AXIS_TREADY(inf.s_axis_tready),
									.S_AXIS_TLAST(inf.s_tlast),
                                    .M_AXIS_TDATA (inf.m_axis_tdata) ,
                                    .M_AXIS_TVALID(inf.m_axis_tvalid),
                                    .M_AXIS_TREADY(inf.m_axis_tready),
									.M_AXIS_TLAST(inf.m_tlast)
                                    );

/*------------------DUT_INSTANCE_END---------------*/

    initial
    begin
        forever
        #4 clk = ~clk;
    end

    initial
    begin  
        rst  =  1;
        #9 ;
        #2 rst  =  0; 
    end

    initial
    begin
        $dumpfile("fir_uvm.vcd");
        $dumpvars(0,top,top.inf);
    end

   initial
   begin
       uvm_config_db#(virtual axi_intf#(`DATA_WIDTH))::set(null, "*", "vif", inf);
       run_test();
   end


endmodule



