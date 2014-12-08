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
          -- Test routine: add r0 <- r1,r2 
  	  if reset='1' then
		memory(0) := jz & r1;    --Test on zero: if yes: jump to addr 6
		memory(1) := "00000110"; --jump addr
                memory(2) := dec & r1;   -- decrement register2
		memory(3) := inc & r0;   -- increment source register r0
		memory(4) := jnz & r1;   -- Test on zero, if not: jump to addr2 
		memory(5) := "00000010";
		memory(6) := jz & r2;
		memory(7) := "00001100";
                memory(8) := dec & r2;
		memory(9) := inc & r0;
		memory(10) := jnz & r2;
		memory(11) := "00001000";
		memory(12) := jmp;
		memory(13) := "00000000";
		memory(14) := "00000000";
		memory(15) := "00000000";
		memory(16) := "00000000";
		memory(17) := "00000000";
		
	  end if; 
	  instruction <= memory(conv_integer(unsigned(inAddr)));
	end process;
end behv;

