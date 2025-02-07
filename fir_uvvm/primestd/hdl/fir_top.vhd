------------------------------------------------------------------------------------------------------------------------
--! @file
--! @brief The unit applies low pass filter and sends output data to avalon-st.
--!
------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief the entity provides the interfaces and generics required by avalon-st
entity fir_top is
  generic (
    data_width  : natural := 16;  --! Width of filter data
	factor		: natural := 2
    );
  port (
    clk   : in std_logic;  --! clock
    reset : in std_logic;  --! reset, active high

    data_input_ready         : out std_logic;  --! indicates that the unit accepts transactions
    data_input_valid         : in  std_logic;  --! indicates that the incoming Avalon-ST transaction is valid
    data_input_startofpacket : in  std_logic;  --! indicates whether an incoming Avalon-ST packet starts
    data_input_endofpacket   : in  std_logic;  --! indicates whether an incoming Avalon-ST packet ends
    data_input_data          : in  std_logic_vector(data_width - 1 downto 0);  --! the incoming Avalon-ST data, including peak/average flag

    data_output_ready         : in  std_logic;  --! indicates if the connected Avalon-ST sink interface accepts data
    data_output_valid         : out std_logic;  --! the transaction is valid
    data_output_startofpacket : out std_logic;  --! signals a sink that a new packet will be sent
    data_output_endofpacket   : out std_logic;  --! signals the end of a packet
    data_output_data          : out std_logic_vector(data_width - 1 downto 0)  --! transaction data
    );
end entity fir_top;

--! @brief the architecture implements the low pass fir filter with configurale 2 or no decimation factor
--! @details the unit does not handle back-pressure and stalls on the input and output Avalon-ST interfaces.
--! The various processes form a logical pipeline as shown in the main page of the documentation.
architecture rtl of fir_top is

  constant SENSOR_TYPE_FIRST_PART     : natural := 0;
  constant SCAN_COUNT_FIRST_PART  : natural := 1;
  constant SCAN_COUNT_SECOND_PART : natural := 2;

  type control_state_type is (control_idle,
                              forward_header,
                              proc_fir_data,
                              wait_fir_end,
                              send_error_word
                              );
  signal control_state : control_state_type;

  signal error_word			 	  	: std_logic_vector(data_width - 1 downto 0);
  signal reset_fir_n		 	  	: std_logic := '0';

  signal fir_data_in               : std_logic_vector(data_width - 1 downto 0);
  signal fir_valid_in              : std_logic;
  
  signal fir_data_out              : std_logic_vector (32 DOWNTO 0);
  signal fir_error_out             : std_logic_vector (1 DOWNTO 0);
  signal fir_data_out_valid        : std_logic;

  -- 21 taps, low pass filter coefficients are hardcoded
  component  fir_lowpass is
  	generic (
-- 21 coefs....	  
		COEFF_0 		: integer := -659;
		COEFF_1 		: integer := -1915;
		COEFF_2 		: integer := -2005;
		COEFF_3 		: integer := -358;
		COEFF_4 		: integer := 1679;
		COEFF_5 		: integer := 1089;
		COEFF_6 		: integer := -1853;
		COEFF_7 		: integer := -2807;
		COEFF_8 		: integer := 2077;
		COEFF_9 		: integer := 10186;
		COEFF_10 		: integer := 14235;
		COEFF_11 		: integer := 10186;
		COEFF_12 		: integer := 2077;
		COEFF_13 		: integer := -2807;
		COEFF_14 		: integer := -1853;
		COEFF_15 		: integer := 1089;
		COEFF_16 		: integer := 1679;
		COEFF_17 		: integer := -358;
		COEFF_18 		: integer := -2005;
		COEFF_19 		: integer := -1915;
		COEFF_20 		: integer := -659;
		NUM_TAPS		: natural := 21;
		DECIMATE_FACTOR	: natural := 2;	-- 1 for no decimation
        INPUT_WIDTH     : natural := 16;  
        OUTPUT_WIDTH    : natural := 33; -- COEF_WIDTH+INPUT_WIDTH+1 sign bit for all stage of additions  	  
        COEF_WIDTH      : natural := 16
  	);
    PORT
    (
	  clk              	: in  std_logic                     := 'X';             -- clk
	  reset_n          	: in  std_logic                     := 'X';             -- reset_n
	  sink_data    		: in  std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => 'X'); -- data
	  sink_valid   		: in  std_logic                     := 'X';             -- valid
	  sink_error   		: in  std_logic_vector(1 downto 0)  := (others => 'X'); -- error
	  source_data  		: out std_logic_vector(OUTPUT_WIDTH-1 downto 0);                    -- data
	  source_valid 		: out std_logic;                                        -- valid
	  source_error 		: out std_logic_vector(1 downto 0)                      -- error
    );
  END component;

begin

  fir:  fir_lowpass
  	generic map (
-- 21 coefs....
		COEFF_0 => -659,
		COEFF_1 => -1915,
		COEFF_2 => -2005,
		COEFF_3 => -358,
		COEFF_4 => 1679,
		COEFF_5 => 1089,
		COEFF_6 => -1853,
		COEFF_7 => -2807,
		COEFF_8 => 2077,
		COEFF_9 => 10186,
		COEFF_10 => 14235,
		COEFF_11 => 10186,
		COEFF_12 => 2077,
		COEFF_13 => -2807,
		COEFF_14 => -1853,
		COEFF_15 => 1089,
		COEFF_16 => 1679,
		COEFF_17 => -358,
		COEFF_18 => -2005,
		COEFF_19 => -1915,
		COEFF_20 => -659,
		NUM_TAPS		=> 21,
		DECIMATE_FACTOR	=> factor,
        INPUT_WIDTH     => 16,  
        OUTPUT_WIDTH    => 33,  
        COEF_WIDTH      => 16
  	)
  port map
  (
      clk      => clk,
      reset_n  => reset_fir_n,
      sink_data    => fir_data_in,
      sink_valid   => fir_valid_in,
      sink_error   => "00",
      source_data    => fir_data_out,
      source_valid   => fir_data_out_valid,
      source_error   => fir_error_out
  );

  --! @anchor control
  --! @brief This is the main control process of fir_top unit.
  --! @details The control process checks if a new data packet is available and starts FIR, 
  --! then forwards filtered output to dataset as per calculated length. 
  control : process(clk, reset)
  variable length_in_count : integer range 0 to 2047;
  variable length_out_count : integer range 0 to 2047;
  variable header_part : integer range 0 to SCAN_COUNT_SECOND_PART;
  variable length_div : integer range 0 to 15;

  begin
    if reset then
      control_state <= control_idle;
	  data_input_ready <= '0';
	  reset_fir_n	<= '0';
    elsif rising_edge(clk) then
      case control_state is
        when control_idle =>
          if data_input_startofpacket and data_input_valid and data_output_ready then
            control_state    <= forward_header;
            data_input_ready <= '1';
          else
            data_input_ready <= '0';
          end if;
		  reset_fir_n	<= '0';
	      fir_valid_in <= '0';
		  length_div := factor;

		  header_part := SENSOR_TYPE_FIRST_PART;
      	  data_output_valid         <= '0';
      	  data_output_startofpacket <= '0';
      	  data_output_endofpacket   <= '0';
      	  data_output_data          <= (others => '0');
		  length_in_count 			:= 0;
		  length_out_count 			:= 0;
		  error_word				<= (others => '0');
		  fir_data_in				<= (others => '0');
		   
        when forward_header =>
		  reset_fir_n				<= '1';
          data_output_endofpacket   <= '0';
  	  	  data_output_data 			<= data_input_data;

          case header_part is
            when SENSOR_TYPE_FIRST_PART =>
           	  data_output_startofpacket                    <= '1';
            when SCAN_COUNT_FIRST_PART | SCAN_COUNT_SECOND_PART =>
              data_output_startofpacket                    <= '0';
          end case;  		    

		  if data_input_endofpacket then
		  	data_input_ready <= '0';
          	data_output_valid		<= '0';
		  	error_word <= data_input_data;
		  	control_state       <= send_error_word;
		  else
		    if (header_part = SCAN_COUNT_SECOND_PART) then
              control_state <= proc_fir_data;
			  data_output_valid		<= '0';
			end if;
          	data_input_ready 		<= '1';
          	data_output_valid		<= '1';
          end if;
		  if(header_part < SCAN_COUNT_SECOND_PART) then
		    header_part := header_part + 1;
		  end if;

        when proc_fir_data =>          	  	  						  
  		  fir_data_in <= data_input_data(15 downto 0);

		  if data_input_endofpacket then
		  	data_input_ready <= '0';
		  	error_word <= data_input_data;
		  	control_state       <= wait_fir_end;
		    fir_valid_in <= '0';
		  else
		    data_input_ready <= '1';
		    fir_valid_in <= data_input_valid;
			if(data_input_valid = '1') then
		      length_in_count := length_in_count + 1;			
		  	end if;
		  end if;
  		  -- truncate 33rd sign bit
		  data_output_data <= fir_data_out(31 downto 16); -- Q16
		  data_output_valid <= fir_data_out_valid;   
		  if(fir_data_out_valid = '1') then
		    length_out_count := length_out_count + 1;
          end if;

        when wait_fir_end => -- only fir data, no headers, no error word
	  	  data_input_ready <= '0';
          if length_out_count >= (length_in_count/length_div) then  		    
            control_state  <= send_error_word;
            data_output_valid <= '0';
			data_output_data <= (others => '-');
		  else
	        if(fir_data_out_valid = '1') then
		      length_out_count := length_out_count + 1;
			end if;
			data_output_valid <= fir_data_out_valid;
			-- truncate 33rd bit sign and divide by Q16
		  	data_output_data <= fir_data_out(31 downto 16);
          end if;	

        when send_error_word =>
		  -- error bits
		  data_output_data <= error_word(error_word'length-2-1 downto 0)& fir_error_out;
		  data_output_valid <= '1';
		  control_state  <= control_idle;
		  data_output_endofpacket <= '1';
		  reset_fir_n	<= '0';
		  fir_data_in <= (others => '0');
		  fir_valid_in <= '0'; 

        when others =>
          control_state <= control_idle;
	  	  data_input_ready <= '0';
		  reset_fir_n	<= '0';
		  fir_data_in <= (others => '0');
		  fir_valid_in <= '0'; 
      end case;
    end if;
  end process;

-- todo, add BIST RAM and logic

end architecture rtl;  -- of fir_top
