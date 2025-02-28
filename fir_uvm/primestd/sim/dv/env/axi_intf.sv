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

interface axi_intf #(parameter DATA_WIDTH = 16) (input clk,rst);

    /*
     * AXI input
     */
    logic [DATA_WIDTH-1:0]          s_axis_tdata;
    logic                           s_axis_tvalid;
    logic                           s_axis_tready;

     /*
      *  AXI Optional signals
      */
 
    logic [7:0]                     s_tid; //maximum 8 bits wide
    logic                           s_tlast;
    logic [3:0]                     s_tdest;
    logic [DATA_WIDTH/8 - 1 :0]     s_tstrb = '1; // default 16 bit per transaction
    logic [DATA_WIDTH/8 - 1 :0]     s_tkeep;

    logic [7:0]                     m_tid; //maximum 8 bits wide
    logic                           m_tlast;
    logic [3:0]                     m_tdest;
    logic [DATA_WIDTH/8 - 1 :0]     m_tstrb = '1; // default 16 bit per transaction
    logic [DATA_WIDTH/8 - 1 :0]     m_tkeep;
    
    /*
     * AXI output
     */
    logic [DATA_WIDTH-1:0]          m_axis_tdata;
    logic                           m_axis_tvalid;
    logic                           m_axis_tready;

    //assert property((@(posedge clk) $rose(s_axis_tvalid) |->  ##[0:16] s_axis_tready)); //16 clocks maximum time for ready to assert

endinterface
