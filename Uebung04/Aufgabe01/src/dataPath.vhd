library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;
use work.lib.ALL;


entity dataPath is
  PORT(
        clk      : IN std_logic;
        reset    : IN std_logic;
        ld0      : IN std_logic;
        ld1      : IN std_logic;
        ld2      : IN std_logic;
        ld3      : IN std_logic;
        mux_ctrl : IN std_logic_vector(2 downto 0);
        alu_ctrl : IN alu_mode;
        r1in     : in  TData;
        r2in     : in  TData;
        pcin     : in  TProgAddr;
        r0out    : out TData;
        r1out    : out TData;
        r2out    : out TData;
        r3out    : out TData;
        alu      : out TData;
        Zout     : OUT std_logic
      );
end dataPath;

architecture behv of dataPath is

signal r0, r1, r2, r3 : TData;
signal alu_in, alu_out : TData;
signal z_flag : std_logic;

begin
  
  register_bank : process(clk, reset)  
  begin
    if reset = '1' then   
      r0 <= (others =>'0');      
      r1 <= r1in; 
      r2 <= r2in;      
      r3 <= (others =>'0');      
    elsif rising_edge(clk) then
      if ld0 = '1' then
        r0 <= alu_out;
      end if;
      if ld1 = '1' then
        r1 <= alu_out;
      end if;
      if ld2 = '1' then
        r2 <= alu_out;
      end if;
      if ld3 = '1' then
        r3 <= alu_out;
      end if;
    end if;    
  end process register_bank;

  mux : process(mux_ctrl, r0, r1, r2, r3, pcin)  
  begin
    case mux_ctrl is
      when "000"     => alu_in <= r0;
      when "001"     => alu_in <= r1;
      when "010"     => alu_in <= r2;
      when "011"     => alu_in <= r3;
      when others => alu_in <= pcin;
    end case;    
  end process mux;

  alu_proc : process(alu_ctrl, alu_in) 
  begin
    case alu_ctrl is
      when  A_INC  => alu_out <= alu_in + '1';
      when  A_DEC  => alu_out <= alu_in - '1';
      when  A_TRAN => alu_out <= alu_in;
    end case;
  end process alu_proc;
  
  status_reg : process(clk, reset)
  begin
    if reset = '1' then   
      z_flag <= '0'; 
    elsif rising_edge(clk) then
      if alu_out = x"0" then
        z_flag <= '1';
      else
        z_flag <= '0';
      end if;
    end if;
  end process status_reg; 
  
  
  Zout <= z_flag;
  alu <= alu_out;
  
  r0out <= r0;
  r1out <= r1;
  r2out <= r2;
  r3out <= r3;
  
end behv;


