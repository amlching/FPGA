------------------------------------------------------------------------------------------------------------------------
--! @file
--! @brief Package for procedures, functions, and constants for fir test bench.
--!
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package fir_sim_helper_pkg is

  --! Avalon-ST packet using an integer array as data array
  type avalon_st_packet_integer_t is record
    data_array         : t_integer_array;  --! streamed data as integer array
    num_received_trans : natural;       --! number of received transactions
    channel            : natural;  --! corresponding channel number for transferred data
    error              : std_logic_vector;  --! bit mask to mark errors
    idle_cycles_array  : t_natural_array;  --! indicates the numbers of idle cycles before sending transactions
  end record;

  --! Avalon-ST packet using standard logic vectors for the data array
  type avalon_st_packet_slv_t is record
    data_array         : t_slv_array;   --! streamed packet as slv array
    num_received_trans : natural;       --! number of received transactions
    channel            : natural;  --! corresponding channel number for transferred data
    error              : std_logic_vector;  --! bit mask to mark errors
    idle_cycles_array  : t_natural_array;  --! indicates the numbers of idle cycles before sending transactions
  end record;

  --! link list element which is an avalon st standard logic vector packet
  type packet_slv;
  --! access pointer to an avalon st standard logic vector packet-based link list element
  type packet_slv_ptr is access packet_slv;
  type packet_slv is record
    packet      : avalon_st_packet_slv_t;
    next_packet : packet_slv_ptr;
  end record packet_slv;

  type packet;
  type packet_ptr is access packet;
  type packet is record
    packet      : avalon_st_packet_integer_t;
    next_packet : packet_ptr;
  end record packet;

  impure function get_samples(
    constant filename : string
    ) return packet_slv_ptr;

  impure function get_fir(
    constant filename : string
    ) return packet_slv_ptr;
end package;

package body fir_sim_helper_pkg is
  impure function get_samples(
    constant filename : string
  ) return packet_slv_ptr is
    constant ID_FIRST_SAMPLE : integer := 3; 
    constant DATA_WIDTH : integer := 16;
	constant SENSOR_TYPE : integer := 170; -- 0xAA
      
    file infile           : text;
    variable inline       : line;
    variable v1, v2, v3   : integer;
    variable space        : character;
    variable head_ptr     : packet_slv_ptr;
    variable tmp_ptr_cur  : packet_slv_ptr;
    variable tmp_ptr_new  : packet_slv_ptr;
    variable header       : std_logic := '1';
    variable sample_count : natural := 0;
    variable scan_count   : natural := 0;
    variable first_sample : boolean := false;
  begin
    file_open(infile, filename, READ_MODE);
    readline(infile, inline);
    read(inline, v1); -- contains scan count
    read(inline, space);
    read(inline, v2); -- contains num_samples
	scan_count := v1;
	sample_count := v2;
    -- +1 for error word
    head_ptr     := new packet_slv(packet(data_array(0 to sample_count-1 + 4)(DATA_WIDTH-1 downto 0),
                                      error(-1 downto 0),
                                      idle_cycles_array(0 to sample_count-1 + 4)));
    tmp_ptr_cur  := head_ptr;
    tmp_ptr_cur.packet.data_array(0) := std_logic_vector(to_unsigned(SENSOR_TYPE, DATA_WIDTH)); 
    tmp_ptr_cur.packet.data_array(1) := std_logic_vector(to_unsigned(scan_count, DATA_WIDTH*2)(15 downto 0));  -- scan count lsb
    tmp_ptr_cur.packet.data_array(2) := std_logic_vector(to_unsigned(scan_count, DATA_WIDTH*2)(31 downto 16));  -- scan count msb

    -- skip remaining header
    for i in 0 to 1 loop
      readline(infile, inline);
    end loop;

    while not endfile(infile) loop
	  for i in 0 to sample_count - 1 loop 
  
      	readline(infile, inline);      
      	read(inline, v1);  -- contains sample number
      	read(inline, space);
      	read(inline, v2);  -- contains sample value
        tmp_ptr_cur.packet.data_array(i + ID_FIRST_SAMPLE) := std_logic_vector(to_signed(v2, DATA_WIDTH));  -- input data

	  end loop;

      readline(infile, inline);
      read(inline, v1);  -- contains 0
      read(inline, space);
      read(inline, v2);  -- contains 0
      read(inline, space);
      read(inline, v3);  -- contains error word 
      tmp_ptr_cur.packet.data_array(tmp_ptr_cur.packet.data_array'right) := std_logic_vector(to_unsigned(v3, DATA_WIDTH)); -- insert error word

      readline(infile, inline);	-- look for next scan
      if not endfile(infile) then
        read(inline, v1);  -- contains scan count
        read(inline, space);
        read(inline, v2);  -- contains num_samples
        scan_count := v1;
		sample_count := v2;

    	-- +1 for error word
        tmp_ptr_new             := new packet_slv(packet(data_array(0 to sample_count-1 + 4)(DATA_WIDTH-1 downto 0),
                                                       error(-1 downto 0),
                                                       idle_cycles_array(0 to sample_count-1 + 4)));
        tmp_ptr_cur.next_packet := tmp_ptr_new;
        tmp_ptr_cur             := tmp_ptr_new;
        tmp_ptr_cur.next_packet := null;

    	tmp_ptr_cur.packet.data_array(0) := std_logic_vector(to_unsigned(SENSOR_TYPE, DATA_WIDTH)); --sensor type
    	tmp_ptr_cur.packet.data_array(1) := std_logic_vector(to_unsigned(scan_count, DATA_WIDTH*2)(15 downto 0));  -- scan count lsb
    	tmp_ptr_cur.packet.data_array(2) := std_logic_vector(to_unsigned(scan_count, DATA_WIDTH*2)(31 downto 16));  -- scan count msb

    	-- skip remaining header
    	for i in 0 to 1 loop
      	  readline(infile, inline);
    	end loop;
      end if;
    end loop;
    file_close(infile);
    return head_ptr;
  end function;

  impure function get_fir(
    constant filename : string
  ) return packet_slv_ptr is
    constant ID_FIRST_SAMPLE   : integer := 3;  
    constant DATA_WIDTH : integer := 16;
	constant SENSOR_TYPE : integer := 170; -- 0xAA
	  
    file infile                 : text;
    variable inline             : line;
    variable v1, v2, v3         : integer;
    variable space              : character;
    variable head_ptr           : packet_slv_ptr;
    variable tmp_ptr_cur        : packet_slv_ptr;
    variable tmp_ptr_new        : packet_slv_ptr;
    variable tmp                : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable fir_count         	: natural := 0;
    variable scan_count         : natural := 0;

  begin
    file_open(infile, filename, READ_MODE);
    readline(infile, inline);
    read(inline, v1);  -- contains scan count number
    read(inline, space);
    read(inline, v2);  -- contains number of expected fir data
    read(inline, space);
    read(inline, v3);
    fir_count := v2;
	scan_count := v1;

    head_ptr                         := new packet_slv(packet(data_array(0 to fir_count-1 + 4)(DATA_WIDTH-1 downto 0),
                                                          error(-1 downto 0),
                                                          idle_cycles_array(0 to fir_count-1 + 4)));
    tmp_ptr_cur                      := head_ptr;
    tmp_ptr_cur.packet.data_array(0) := std_logic_vector(to_unsigned(SENSOR_TYPE, DATA_WIDTH)); --sensor type
    tmp_ptr_cur.packet.data_array(1) := std_logic_vector(to_unsigned(scan_count, DATA_WIDTH*2)(15 downto 0));  -- scan count lsb
    tmp_ptr_cur.packet.data_array(2) := std_logic_vector(to_unsigned(scan_count, DATA_WIDTH*2)(31 downto 16));  -- scan count msb

    while not endfile(infile) loop

      for i in 0 to fir_count - 1 loop
        readline(infile, inline);
      	read(inline, v1);  -- sample#
     	read(inline, space);
      	read(inline, v2);  -- contains fir data
        tmp_ptr_cur.packet.data_array(i + ID_FIRST_SAMPLE) := std_logic_vector(to_signed(v2, 16));  -- filtered data
	  end loop;

      -- Todo: confirm error bits to extract from raw ADC packet, update create_sim_data.c generates zero error bits for now
      readline(infile, inline);
	  -- copy same error bits  
   	  read(inline, v1);  -- contains error bits
      tmp_ptr_cur.packet.data_array(fir_count-1 + 4) := std_logic_vector(to_unsigned(v1, DATA_WIDTH)); -- header + error word offset 

      readline(infile, inline);
      if not endfile(infile) then
          read(inline, v1);  -- contains scan count number
          read(inline, space);
          read(inline, v2);  -- contains number of expected fir
          read(inline, space);
          read(inline, v3);
    	  fir_count := v2;
		  scan_count := v1;

          tmp_ptr_new := new packet_slv(packet(data_array(0 to fir_count-1 + 4)(DATA_WIDTH-1 downto 0),
                                           error(-1 downto 0),
                                           idle_cycles_array(0 to fir_count-1 + 4)));
          tmp_ptr_cur.next_packet          := tmp_ptr_new;
          tmp_ptr_cur                      := tmp_ptr_new;
          tmp_ptr_cur.next_packet          := null;
    	  tmp_ptr_cur.packet.data_array(0) := std_logic_vector(to_unsigned(SENSOR_TYPE, DATA_WIDTH)); --sensor type
    	  tmp_ptr_cur.packet.data_array(1) := std_logic_vector(to_unsigned(scan_count, DATA_WIDTH*2)(15 downto 0));  -- scan count lsb
    	  tmp_ptr_cur.packet.data_array(2) := std_logic_vector(to_unsigned(scan_count, DATA_WIDTH*2)(31 downto 16));  -- scan count msb

      end if;
    end loop;
    file_close(infile);
    return head_ptr;
  end function;
end package body;
