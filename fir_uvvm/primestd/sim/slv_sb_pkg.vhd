------------------------------------------------------------------------------------------------------------------------
--! @file
--! @brief Package for scoreboard.
--!
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

-- scoreboard declaration
package slv_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg
generic map(t_element         => std_logic_vector(15 downto 0),
            element_match     => std_match,
            to_string_element => to_string,
            sb_config_default => C_SB_CONFIG_DEFAULT);
