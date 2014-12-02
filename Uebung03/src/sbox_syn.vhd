library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use WORK.aes_package.all;


entity sbox_syn is 
  port (
     reset    : in std_logic;
     clock    : in std_logic;
     write    : in std_logic;
     data_in  : in std_logic_vector (127 downto 0);
     done     : out std_logic;
     data_out : out std_logic_vector (127 downto 0);
     count_var_out : out std_logic_vector(3 downto 0)
    );     
end sbox_syn;

architecture sbox_RTL of sbox_syn is


type states is (RUNNING, IDLE);


signal state, state_next : states;


signal done_tmp : std_logic;
signal data : std_logic_vector (127 downto 0);
signal ce : std_logic; -- chip enable
type count_mode is (LOAD, COUNT); 
signal count_ctrl : count_mode;
signal count_var : std_logic_vector (3 downto 0);

signal sbox_in, sbox_out : std_logic_vector (7 downto 0);

begin

delta_lambda_cu : process(state, write, count_var)
begin
  case state is
    when IDLE    =>  done_tmp <= '1';
                     if write = '1' then
                       ce <= '1';
                       count_ctrl <= COUNT; 
                       state_next <= RUNNING;
                     else
                       ce <= '0'; 
                       count_ctrl <= LOAD;
                       state_next <= IDLE;
                     end if;
    
    when RUNNING =>  done_tmp <= '0';
                     ce <= '1';
                     if count_var < x"F" then
                       count_ctrl <= COUNT;
                       state_next <= RUNNING;
                     else
                       count_ctrl <= LOAD;
                       state_next <= IDLE;
                     end if;
  end case;
end process delta_lambda_cu;


fb_cu : process(clock, reset)
begin  
  if reset = '1' then
    state <= IDLE;
  elsif clock'event and clock = '1' then
    state <= state_next;
  end if;
end process fb_cu; 


counter : process(clock, reset)
begin
  if reset = '1' then
    count_var <= x"0";
  elsif clock'event and clock = '1' then
    case count_ctrl is
      when COUNT => count_var <= count_var + x"1"; 
      when LOAD  => count_var <= x"0"; 
    end case;
  end if;
end process counter;


mux : process(count_var, data_in)
begin
  case count_var is
    when x"0" => sbox_in <= data_in (127 downto 120);
    when x"1" => sbox_in <= data_in (119 downto 112);
    when x"2" => sbox_in <= data_in (111 downto 104);
    when x"3" => sbox_in <= data_in (103 downto 96);
    when x"4" => sbox_in <= data_in (95 downto 88);
    when x"5" => sbox_in <= data_in (87 downto 80);
    when x"6" => sbox_in <= data_in (79 downto 72);
    when x"7" => sbox_in <= data_in (71 downto 64);
    when x"8" => sbox_in <= data_in (63 downto 56);
    when x"9" => sbox_in <= data_in (55 downto 48);
    when x"A" => sbox_in <= data_in (47 downto 40);
    when x"B" => sbox_in <= data_in (39 downto 32);
    when x"C" => sbox_in <= data_in (31 downto 24);
    when x"D" => sbox_in <= data_in (23 downto 16);
    when x"E" => sbox_in <= data_in (15 downto 8);
    when others => sbox_in <= data_in (7 downto 0);
 end case;
end process mux;


demux_and_reg : process(clock)
begin
  if clock'event and clock ='1' then
    if ce = '1' then
      case count_var is
        when x"0" => data (127 downto 120) <= sbox_out;
        when x"1" => data (119 downto 112) <= sbox_out;
        when x"2" => data (111 downto 104) <= sbox_out;
        when x"3" => data (103 downto 96) <= sbox_out;
        when x"4" => data (95 downto 88) <= sbox_out;
        when x"5" => data (87 downto 80) <= sbox_out;
        when x"6" => data (79 downto 72) <= sbox_out;
        when x"7" => data (71 downto 64) <= sbox_out;
        when x"8" => data (63 downto 56) <= sbox_out;
        when x"9" => data (55 downto 48) <= sbox_out;
        when x"A" => data (47 downto 40) <= sbox_out;
        when x"B" => data (39 downto 32) <= sbox_out;
        when x"C" => data (31 downto 24) <= sbox_out;
        when x"D" => data (23 downto 16) <= sbox_out;
        when x"E" => data (15 downto 8) <= sbox_out;
        when others => data (7 downto 0) <= sbox_out;
      end case;
    end if;
  end if;
end process demux_and_reg;


sbox_out <= sbox_fun(sbox_in);
data_out <= data;
done <= done_tmp;

count_var_out <= count_var;
end sbox_RTL;

