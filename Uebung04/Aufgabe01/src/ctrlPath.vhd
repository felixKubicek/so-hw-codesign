Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

use work.lib.ALL;


entity ctrlPath is
  PORT(
        clk    : IN std_logic;
        reset  : IN std_logic;
        --Zin    : IN std_logic;
        alu_in : IN  TData;
        pc_out : OUT TProgAddr;
        addr   : OUT TProgAddr;
        instruction : IN TInstruction;
        ld0    : OUT std_logic;
        ld1    : OUT std_logic;
        ld2    : OUT std_logic;
        ld3    : OUT std_logic;
        mux_ctrl : OUT std_logic_vector(1 downto 0);
        alu_ctrl : OUT std_logic_vector(1 downto 0)
      );
end ctrlPath;

architecture behv of ctrlPath is

signal pc, mar : TProgAddr;
signal pc_ce : std_logic;

begin








mar_reg : process(clk, reset)
  if reset = '1' then
    mar <= (others=>'0');
  elsif rising_edge(clk) then
    mar <= pc;
  end if;
end process mar_reg;

pc_reg : process(clk, reset)
  if reset = '1' then
    pc <= (others=>'0');
  elsif rising_edge(clk) then
    if pc_ce = '1' then
      pc <= alu_in;
    end if:
  end if;
end process pc_reg;

pc_out <= pc;
addr <= mar;

end behv;

