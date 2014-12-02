Library IEEE;
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
        r2in     : in  TData;
        r3in     : in  TData;
        pcin     : in  TProgAddr;
        r0out    : out TData;
        r1out    : out TData;
        r2out    : out TData;
        r3out    : out TData;
        alu      : out TData;
        Zout     : OUT std_logic
      );
end dataPath;

signal r0, r1, r2, r3 : TData;
signal alu_in, alu_out : TData;
signal z_flag : std_logic;

architecture behv of dataPath is
begin
  
  register_bank : process(clk, reset)  
  begin
    if reset = '1' then   
      r0 <= (others =>'0');      
      r1 <= (others =>'0');      
      r2 <= r2in, 
      r3 <= r3in;      
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
    case 0 & mux_ctrl is
      when R0     => alu_in <= r0;
      when R1     => alu_in <= r1;
      when R2     => alu_in <= r2;
      when R3     => alu_in <= r3;
      when others => alu_in <= pcin;
    end case;    
  end process mux;

  alu : process(alu_ctrl, alu_in) 
  begin
    case alu_ctrl is
      when  A_INC  => alu_out <= alu_in + '1';
      when  A_DEC  => alu_out <= alu_in - '1';
      when  A_TRAN => alu_out <= alu_in;
    end case;
  end process alu;
  
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
  (r0out, r1out, r2out, r3out) <= (r0, r1, r2, r3);
  
end behv;


