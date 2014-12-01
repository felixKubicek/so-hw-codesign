Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_textio.ALL;
use IEEE.std_logic_unsigned.ALL;
LIBRARY STD;
USE std.textio.ALL;

use work.lib.ALL;

entity pMemory is
  PORT(
        --clk    : IN std_logic;
        reset  : IN std_logic;
        inAddr : IN TProgAddr;
        
        instruction : OUT TInstruction
      );
end pMemory;

architecture behv of pMemory is
  constant max_ram_count      : integer :=127;
begin
	memory_process : process (inAddr, reset)
	type ram is array (0 to max_ram_count) of TInstruction;
	variable memory     : ram := (others => (others => '0'));

	begin
  	  if reset='1' then
		memory(0) := jz & r2;     --Test on zero: if yes: jump to addr 5
		memory(1) := "00000101";  --jump addr
		memory(2) := dec & r2;   -- decrement register2
		memory(3) := jnz & r2;   -- Test on zero, if not: jump to addr2 
		memory(4) := "00000010";
		memory(5) := jz & r3;
		memory(6) := "00001001";
		memory(7) := dec & r3;
		memory(8) := jnz & r3;
		memory(9) :=  "00000111";
		memory(10) := "10000000";
		memory(11) := "00000000";
		memory(12) := "00000000";
		memory(13) := "00000000";
		memory(14) := "00000000";
		memory(15) := "00000000";
		
	  end if; 
	  instruction <= memory(conv_integer(unsigned(inAddr)));
	end process;
end behv;

