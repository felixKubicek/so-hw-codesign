library ieee;
use ieee.std_logic_1164.all;

entity sbox_tb is
end sbox_tb;

architecture tb_architecture of sbox_tb is

component sbox
  port (
     data_in  : in std_logic_vector(127 downto 0);
     data_out : out std_logic_vector(127 downto 0)
    );     
end component;

signal data_in : std_logic_vector(127 downto 0) := (others => '0');
signal data_out : std_logic_vector(127 downto 0):= (others => '0');
signal clock : std_logic;
constant clock_period :TIME := 30 ns;

begin

uut: sbox
port map (
   data_in => data_in,
   data_out => data_out
);


process
begin
   clock <='0'; 
   wait for clock_period/2;
   clock<='1';
   wait for clock_period/2;
end process;

process
begin   
   
   data_in <= x"19a09ae93df4c6f8e3e28d48be2b2a08";
   wait for 1 ns; 
   assert data_out = x"d4e0b81e27bfb44111985d52aef1e530";
   
   data_in <= x"a4686b029c9f5b6a7f35ea50f22b4349";
   wait for 1 ns; 
   assert data_out = x"49457f77dedb3902d296875389f11a3b";
  
  
   -- wrong input  
   data_in <= x"aa6182688fddd2325fe34a4603efd29a";
   wait for 1 ns;
   -- wrong output 
   assert data_out /= x"49457f77dedb3902d296875389f11a3b";
   
   wait for 100 ns;
   wait;
end process;

end tb_architecture;


