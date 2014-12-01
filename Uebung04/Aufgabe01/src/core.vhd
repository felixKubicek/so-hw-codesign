Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;
use work.lib.ALL;

entity core is
  PORT(
      clk       : IN std_logic;
      reset     : IN std_logic;
      reg0      : OUT TData;
      reg1      : OUT TData;
      reg2      : OUT TData;
      reg3      : OUT TData;
      reg1input : IN TData;
      reg2input : IN TData
      );
end core;

architecture behavior of core is			



end behavior;

