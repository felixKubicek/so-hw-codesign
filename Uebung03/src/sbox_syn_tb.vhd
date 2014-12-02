library ieee;
use ieee.std_logic_1164.all;

entity sbox_syn_tb is
end sbox_syn_tb;

architecture tb_architecture of sbox_syn_tb is

component sbox_syn
  port (
     reset    : in std_logic;
     clock    : in std_logic;
     write    : in std_logic;
     data_in  : in std_logic_vector(127 downto 0);
     done     : out std_logic;
     data_out : out std_logic_vector(127 downto 0);
     count_var_out : out std_logic_vector (3 downto 0)
    );     
end component;


signal clock, reset, write : std_logic;
signal data_in : std_logic_vector(127 downto 0) := (others => '0');
signal done : std_logic;
signal data_out : std_logic_vector(127 downto 0);
signal count_var_out : std_logic_vector (3 downto 0);

constant clock_period :TIME := 30 ns; 

begin

uut: sbox_syn
port map (
   clock => clock,
   reset => reset, 
   write => write,
   data_in => data_in,
   done => done,
   data_out => data_out,
   count_var_out => count_var_out
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
   reset<='1';
   
   wait for clock_period;
   
   reset <= '0'; 
   
   data_in <= x"19a09ae93df4c6f8e3e28d48be2b2a08";
   write <= '1';
   assert done = '1';

   wait for clock_period;
   -- subbytes running -> done flag active low
   assert done = '0';
   write <= '0';
   wait for clock_period * 15;
   -- result available after 16 clock cycles
   assert done = '1';
   assert data_out = x"d4e0b81e27bfb44111985d52aef1e530";
   
   -- wait in idle state until write signal gets active high
   wait for clock_period * 10;
   -- done flag still active high & result is still aviailable
   assert done = '1';
   assert data_out = x"d4e0b81e27bfb44111985d52aef1e530";


   data_in <= x"a4686b029c9f5b6a7f35ea50f22b4349";
   write <= '1';
   wait for clock_period * 15;
   -- not yet finished
   assert data_out /= x"49457f77dedb3902d296875389f11a3b";
   assert done = '0';
   
   wait for clock_period; 
   -- now finished
   assert data_out = x"49457f77dedb3902d296875389f11a3b";
   assert done = '1';

   wait for clock_period; 
   -- write signal still active high -> result only valid for one clock cycle
   assert done = '0';
   write <= '0';
 
   data_in <= x"aa6182688fddd2325fe34a4603efd29a";
   wait for clock_period * 15;
   -- wrong output
   assert data_out /= x"49457f77dedb3902d296875389f11a3b";
   assert done = '1';

   wait for 100 ns;
   -- still in idle state
   assert done = '1';
   wait;

   wait;
end process;

end tb_architecture;


