------------------------------------------------------------------------------------------------------------------------
--! @file
--! @brief fir test bench.
--!
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.all;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
use uvvm_vvc_framework.ti_protected_types_pkg.all;

library bitvis_vip_avalon_st;
use bitvis_vip_avalon_st.avalon_st_bfm_pkg.all;
use bitvis_vip_avalon_st.vvc_methods_pkg.all;
use bitvis_vip_avalon_st.transaction_pkg.all;
use bitvis_vip_avalon_st.td_vvc_framework_common_methods_pkg.all;

use work.fir_sim_helper_pkg.all;

entity fir_tb is
end;

architecture behave of fir_tb is
  constant NUM_FILES : integer := 1;
begin
  test_harness : entity work.fir_th;

--------------------------------------------------------------------------------
-- Sequential logic
--------------------------------------------------------------------------------
-- main control process
  T1_test_sequencer : process
    alias CLK_PERIOD is << constant .fir_tb.test_harness.CLK_PERIOD                      : time >>;
    alias reset is << signal .fir_tb.test_harness.reset                                  : std_logic >>;
	alias clk is << signal .fir_tb.test_harness.clk										 : std_logic >>;

    variable wait_completion : std_logic;
    variable data            : packet_slv_ptr;
    variable exp_fir       	 : packet_slv_ptr;

    --! @brief Test back to back scans, with files generated from C model
    --! @param number_files number of processed files
    --! @param idles number of idle cycles
    procedure test_files_c_model(number_files : in integer := NUM_FILES; idles : in natural := 0) is
    begin
      log(ID_LOG_HDR, "Test: back to back processing (multiple scans and different input and output data from C model)");

      for file_id in 1 to number_files loop
        log(ID_LOG_HDR, "File: " & to_string(file_id));
        data     := get_samples("generate_testdata/stimulus_test" & to_string(file_id) & ".txt");
        exp_fir  := get_fir("generate_testdata/fir_data" & to_string(file_id) & ".txt");
						  
        while exp_fir /= null loop

		  avalon_st_transmit(AVALON_ST_VVCT, 1, data.packet.data_array, "send sample data");
--		  avalon_st_expect(AVALON_ST_VVCT, 2, exp_fir.packet.data_array, "expect fir data"); -- avalon_st_expect has bug in channel assignment, check data in wave.do
		  avalon_st_receive(AVALON_ST_VVCT, 2, exp_fir.packet.data_array'length, exp_fir.packet.data_array(1)'length, "receive fir data");

          data     := data.next_packet;
          exp_fir  := exp_fir.next_packet;
 
          await_completion(AVALON_ST_VVCT, 1, 200000 * CLK_PERIOD);
          await_completion(AVALON_ST_VVCT, 2, 200000 * CLK_PERIOD);

        end loop;
      end loop;
    end procedure;

  begin
    await_uvvm_initialization(VOID);

    set_log_file_name("sim_log_fir.txt");

    disable_log_msg(ID_BLOCKING, QUIET);
    disable_log_msg(ID_POS_ACK, QUIET);
    disable_log_msg(ID_UVVM_SEND_CMD, QUIET);
    disable_log_msg(ID_UVVM_CMD_ACK, QUIET);
    disable_log_msg(ID_CMD_EXECUTOR_WAIT, QUIET);
    disable_log_msg(ID_CMD_INTERPRETER_WAIT, QUIET);
    disable_log_msg(ID_UVVM_CMD_RESULT, QUIET);
    disable_log_msg(ID_PACKET_DATA);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    gen_pulse(reset, 100 ns, BLOCKING, "Pulsing DUT reset 100 ns");

    ------------------------
    -- send back to back scans, with files generated from C model, 0 stalls/back pressure
    test_files_c_model(NUM_FILES, 5);
    wait for 10 * CLK_PERIOD;

    report_alert_counters(FINAL);
    -- Finish the simulation
    std.env.stop;
    wait;
  end process;
end architecture;
