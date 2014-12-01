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
        mux_ctrl : OUT std_logic_vector(2 downto 0);
        alu_ctrl : OUT alu_mode
      );
end ctrlPath;

architecture behv of ctrlPath is

signal pc, mar : TProgAddr;
signal ir : TInstruction;


type pc_mode is (PC_ALU_IN, PC_MEM_IN);
signal pc_ctrl : pc_mode; 
signal pc_ce, ir_ce : std_logic;

signal timer_val : std_logic_vector(3 downto 0);
type timer_mode is (T_INC, T_LOAD);
signal timer_ctrl : timer_mode;



begin

  fsm_cu : process(state)
  begin
    
    -- default: hold register values
    (ld0,ld1,ld2,ld3) <= ('0', '0', '0', '0');
    -- default: increment timer
    timer_ctrl <= T_INC;
    -- default: PC receives output values of the ALU
    pc_ctrl <= PC_ALU_IN;
    -- default: ALU just transfers value
    alu_ctrl <= A_TRAN;
    
    if timer = x"0" then
      -- IR = IR
      ir_ce <= '0';
      -- PC = PC
      pc_ce <= '0';  
      mux_ctrl <= "---";
      
    elsif timer = x"1" then
      -- IR = MEM[PC]
      ir_ce <= '1';
      -- PC = PC +1
      pc_ce <= '1';
      mux_ctrl <= "100";
      alu_ctrl <= A_INC;
    
    elsif timer = x"2"  
      case ir (7 downto 4) is 
        when JMP =>
        
        
        when JZ  =>    mux_ctrl <= ir (2 downto 0);
                       alu_ctrl <= A_TZ;
                       
                       if (alu_in = x"0") then
                         
                         timer_ctrl <= T_LOAD
                       
                      
        
        when JNZ =>    mux_ctrl <= ir (2 downto 0);
                       alu_ctrl <= A_TZ;
        
        when INC =>    mux_ctrl <= ir (2 downto 0);
                       alu_ctrl <= A_INC;
                       
                       if    ir(3 downto 0) = R0 then ld0 <= '1';
                       elsif ir(3 downto 0) = R1 then ld1 <= '1';
                       elsif ir(3 downto 0) = R2 then ld2 <= '1';
                       elsif ir(3 downto 0) = R3 then ld3 <= '1';  
                       end if;
                       -- finished
                       timer_ctrl <= T_LOAD;    
        -- dec
        when others => mux_ctrl <= ir (2 downto 0);
                       alu_ctrl <= A_DEC;
                       
                       if    ir(3 downto 0) = R0 then ld0 <= '1';
                       elsif ir(3 downto 0) = R1 then ld1 <= '1';
                       elsif ir(3 downto 0) = R2 then ld2 <= '1';
                       elsif ir(3 downto 0) = R3 then ld3 <= '1';  
                       end if;
                       -- finished
                       timer_ctrl <= T_LOAD;
      end case;
      
    end if;




  end process fsm_cu;

  
  timer_mux_reg : process(clk, reset)
  begin
    if reset = '1' then
      timer <= (others=>'0');
    elsif rising_edge(clk) then  
      case timer_ctl is 
        when T_INC  => timer <= timer + '1';
        when T_LOAD => timer <= '0';
      end case;
    end if;
  end process timer_mux_reg;  


  ir_reg : process(clk, reset)
  begin
    if reset = '1' then
      ir <= (others=>'0');
    elsif rising_edge(clk) then
      if ir_ce = '1' then
        ir <= instruction;
      end if;
    end if;
  end process ir_reg;


  mar_reg : process(clk, reset)
  begin
    if reset = '1' then
      mar <= (others=>'0');
    elsif rising_edge(clk) then
      mar <= pc;
    end if;
  end process mar_reg;

  
  pc_mux_reg : process(clk, reset)
  begin
    if reset = '1' then
      pc <= (others=>'0');
    elsif rising_edge(clk) then
      if pc_ce = '1' then
        case pc_ctl is 
          when PC_ALU_IN => pc <= alu_in;
          when PC_MEM_IN => pc <= instruction;
        end case;
      end if;
    end if;
  end process pc_mux_reg;

  pc_out <= pc;
  addr <= mar;

end behv;

