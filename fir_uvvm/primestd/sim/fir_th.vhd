------------------------------------------------------------------------------------------------------------------------
--! @file
--! @brief Test harness for fir unit.
--!
------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.all;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_avalon_st;
use bitvis_vip_avalon_st.avalon_st_bfm_pkg.all;

library work;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
entity fir_th is
end;

architecture behave of fir_th is
--  constant CLK_PERIOD 		: time    := 16.666 ns;  -- filter sample at 60 MHz, 0 to 12MHz passes through, 15MHz to 30MHz blocked
  constant CLK_PERIOD 		: time    := 500 ns;  -- filter sample at 2 KHz, 0 400Hz passes through, 500Hz to 1KHz blocked
  constant DATA_WIDTH    	: integer := 16;
  constant GC_CHANNEL_WIDTH	: integer := 1; -- was 1
  constant GC_ERROR_WIDTH	: integer := 1; -- was 0
  constant GC_EMPTY_WIDTH	: integer := 1; -- check against log2(symbols_per_beat), symbols_per_beat = avalon data length/symbol_width

  constant DATA_AVALON_ST_CONFIG : t_avalon_st_bfm_config := (
    max_wait_cycles          => 800000,
    max_wait_cycles_severity => TB_FAILURE,
    clock_period             => CLK_PERIOD,
    clock_period_margin      => 0 ns,
    clock_margin_severity    => TB_ERROR,
    setup_time               => -1 ns,
    hold_time                => -1 ns,
    bfm_sync                 => SYNC_ON_CLOCK_ONLY,
    match_strictness         => MATCH_EXACT,
    symbol_width             => 16,
    first_symbol_in_msb      => true,
    max_channel              => GC_CHANNEL_WIDTH,
    use_packet_transfer      => true,
    id_for_bfm               => ID_BFM
  );

  signal data_in : t_avalon_st_if(data(DATA_WIDTH - 1 downto 0),
                                  channel(GC_CHANNEL_WIDTH -1 downto 0),
                                  data_error(GC_ERROR_WIDTH - 1 downto 0),
                                  empty(GC_EMPTY_WIDTH - 1 downto 0))
	:= init_avalon_st_if_signals(true, GC_CHANNEL_WIDTH, DATA_WIDTH, GC_ERROR_WIDTH, GC_EMPTY_WIDTH);

  signal data_out : t_avalon_st_if(data(DATA_WIDTH - 1 downto 0),
                                   channel(GC_CHANNEL_WIDTH - 1 downto 0),
                                   data_error(GC_ERROR_WIDTH - 1 downto 0),
                                   empty(GC_EMPTY_WIDTH - 1 downto 0))
	:= init_avalon_st_if_signals(false, GC_CHANNEL_WIDTH, DATA_WIDTH, GC_ERROR_WIDTH, GC_EMPTY_WIDTH);

  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';

begin
  engine : entity uvvm_vvc_framework.ti_uvvm_engine;

-------------------------------------------------------
-- Continuous assignments
-------------------------------------------------------
  clock_generator(clk, CLK_PERIOD);     -- system clock

-------------------------------------------------------
-- Entity instantiation
-------------------------------------------------------
  -- BFM to DUT
  data_in_0 : entity bitvis_vip_avalon_st.avalon_st_vvc
    generic map(
      GC_VVC_IS_MASTER			  => true,
      GC_DATA_WIDTH               => DATA_WIDTH,
      GC_CHANNEL_WIDTH            => GC_CHANNEL_WIDTH,
	  GC_DATA_ERROR_WIDTH		  => GC_ERROR_WIDTH,
      GC_EMPTY_WIDTH              => GC_EMPTY_WIDTH,
      GC_INSTANCE_IDX             => 1,
      GC_AVALON_ST_BFM_CONFIG 	  => DATA_AVALON_ST_CONFIG
      )
    port map (
      clk                  		=> clk,
      avalon_st_vvc_if 			=> data_in
      );

  dut : entity work.fir_top
    port map(
      clk                      		 => clk,
      reset                    		 => reset,
      data_input_ready               => data_in.ready,
      data_input_valid               => data_in.valid,
      data_input_startofpacket       => data_in.start_of_packet,
      data_input_endofpacket         => data_in.end_of_packet,
      data_input_data                => data_in.data,
      data_output_ready              => data_out.ready,
      data_output_valid              => data_out.valid,
      data_output_startofpacket      => data_out.start_of_packet,
      data_output_endofpacket        => data_out.end_of_packet,
      data_output_data               => data_out.data
      );

  -- DUT to BFM
  data_out_0 : entity bitvis_vip_avalon_st.avalon_st_vvc
    generic map(
      GC_VVC_IS_MASTER			   => false,
      GC_DATA_WIDTH                => DATA_WIDTH,
      GC_CHANNEL_WIDTH             => GC_CHANNEL_WIDTH,
	  GC_DATA_ERROR_WIDTH		   => GC_ERROR_WIDTH,
      GC_EMPTY_WIDTH               => GC_EMPTY_WIDTH,
      GC_INSTANCE_IDX              => 2,
      GC_AVALON_ST_BFM_CONFIG 	   => DATA_AVALON_ST_CONFIG
      )
    port map (
      clk                   => clk,
      avalon_st_vvc_if 		=> data_out
      );

end behave;
