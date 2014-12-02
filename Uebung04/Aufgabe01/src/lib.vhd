library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

package lib is

	constant WIDTH : natural := 8;
	constant JMP   : std_logic_vector(7 downto 0) := "10000000";
	constant JZ   : std_logic_vector(3 downto 0) := "1001";
	constant JNZ   : std_logic_vector(3 downto 0) := "1010";
	constant INC   : std_logic_vector(3 downto 0) := "0001";
	constant DEC   : std_logic_vector(3 downto 0) := "0010";
	constant R0   : std_logic_vector(3 downto 0) := "0000";
	constant R1   : std_logic_vector(3 downto 0) := "0001";
	constant R2   : std_logic_vector(3 downto 0) := "0010";
	constant R3   : std_logic_vector(3 downto 0) := "0011";
	
	subtype TInstruction is std_logic_vector(WIDTH - 1 downto 0);
	subtype TProgAddr is std_logic_vector(WIDTH - 1 downto 0);
	subtype TData is std_logic_vector(WIDTH - 1 downto 0);
  
  type alu_mode is (A_INC, A_DEC, A_TRAN);	
	
end package lib;

--! package body of lib
package body lib is

end package body;


