Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

use work.lib.ALL;


entity ctrlPath is
  PORT(
        clk    : IN std_logic;
        reset  : IN std_logic;
        Zin    : IN std_logic;
        alu    : IN  TData;
        pc_out : OUT TProgAddr;
        addr   : OUT TProgAddr;
        instruction : IN TInstruction;
        ld0    : OUT std_logic;
        ld1    : OUT std_logic;
        ld2    : OUT std_logic;
        ld3    : OUT std_logic;
        mux_ctrl : OUT std_logic_vector(2 downto 0);
        alu_ctrl : OUT alu_mode;
        timer_out : OUT std_logic_vector(1 downto 0)
      );
end ctrlPath;

architecture behv of ctrlPath is

signal pc, mar : TProgAddr;
signal ir : TInstruction;


type pc_mode is (PC_ALU_IN, PC_MEM_IN);
signal pc_ctrl : pc_mode; 
signal pc_ce, ir_ce : std_logic;

signal timer : std_logic_vector(1 downto 0);
type timer_mode is (T_INC, T_LOAD);
signal timer_ctrl : timer_mode;

begin

  fsm_cu : process(timer, ir, Zin)
    constant JMP_CHOICE : std_logic_vector(3 downto 0) := "1000";
    constant JZ_CHOICE  : std_logic_vector(3 downto 0) := "1001";
    constant JNZ_CHOICE : std_logic_vector(3 downto 0) := "1010";
    constant INC_CHOICE : std_logic_vector(3 downto 0) := "0001";
    constant DEC_CHOICE : std_logic_vector(3 downto 0) := "0010";
  begin
    
    -- default: hold register values
    ld0 <= '0';
    ld1 <= '0';
    ld2 <= '0';
    ld3 <= '0';
    -- default: increment timer
    timer_ctrl <= T_INC;
    -- default: PC receives output values of the ALU
    pc_ctrl <= PC_ALU_IN;
    -- default: ALU just transfers value
    alu_ctrl <= A_TRAN;
    -- default: disable instruction register
    ir_ce <= '0';
     -- default: disable pc register
    pc_ce <= '0';
    
    -- fetch 1
    if timer = x"0" then
      -- MAR <= PC;
      mux_ctrl <= "---";
    
    -- fetch 2  
    elsif timer = x"1" then
      -- IR <= MEM[MAR];
      ir_ce <= '1';
      -- PC = PC + 1;
      pc_ce <= '1';
      mux_ctrl <= PC_IN;
      alu_ctrl <= A_INC;
    
    -- execute 1 
    elsif timer = x"2" then 
      case ir(7 downto 4) is         
         
        -- jmp1
                           -- MAR <= PC;
        when JMP_CHOICE => mux_ctrl <= "---";
                           -- bad instruction
                           if ir(3 downto 0) /= "0000" then
                             timer_ctrl <= T_LOAD;
                           end if;
                      
        -- jz1
                            -- MAR <= PC;
                            -- set z_flag
        when JZ_CHOICE  => mux_ctrl <= ir (2 downto 0);
                                      
         
        -- jnz1
                              -- MAR <= PC;
                              -- set z_flag
        when JNZ_CHOICE => mux_ctrl <= ir (2 downto 0);
        
        -- inc1              -- MAR <= PC;
                             -- increment
        when INC_CHOICE => mux_ctrl <= ir (2 downto 0);
                           alu_ctrl <= A_INC;
                           -- write back result
                           if    ir(3 downto 0) = R0 then ld0 <= '1';
                           elsif ir(3 downto 0) = R1 then ld1 <= '1';
                           elsif ir(3 downto 0) = R2 then ld2 <= '1';
                           elsif ir(3 downto 0) = R3 then ld3 <= '1';  
                           end if;
                           -- return to fetch1
                           timer_ctrl <= T_LOAD;    
        
        -- dec1
                             -- MAR <= PC;
                             -- decrement
        when DEC_CHOICE => mux_ctrl <= ir (2 downto 0);
                           alu_ctrl <= A_DEC;
                           -- write back result
                           if    ir(3 downto 0) = R0 then ld0 <= '1';
                           elsif ir(3 downto 0) = R1 then ld1 <= '1';
                           elsif ir(3 downto 0) = R2 then ld2 <= '1';
                           elsif ir(3 downto 0) = R3 then ld3 <= '1';  
                           end if;
                           -- return to fetch1‚
                           timer_ctrl <= T_LOAD;
        
        -- bad instruction
        when others => mux_ctrl <= "---";
                       timer_ctrl <= T_LOAD;
	               
      end case;
    
    -- execute 2
    elsif timer = x"3" then
      case ir(7 downto 4) is         
         
        -- jmp2
                            
        when JMP_CHOICE => if ir(3 downto 0) = "0000" then
                             -- PC = MEM[MAR]; (addr)
                             pc_ce <= '1';
                             pc_ctrl <= PC_MEM_IN;
                             -- return to fetch1‚
                             timer_ctrl <= T_LOAD;
                           else
                             -- bad instruction
                              mux_ctrl <= "---";
                              timer_ctrl <= T_LOAD;
                           end if;
 
        -- jz2
        when  JZ_CHOICE => if Zin = '1' then
                               --  PC = MEM[MAR]; (addr)
                               pc_ce <= '1';
                               pc_ctrl <= PC_MEM_IN;
                             else
                               -- PC = PC + 1;
                               pc_ce <= '1';
                               mux_ctrl <= PC_IN;
                               alu_ctrl <= A_INC;
                             end if;
                             -- return to fetch1‚
                             timer_ctrl <= T_LOAD;
        -- jnz2
        when JNZ_CHOICE => if Zin = '0' then
                               --  PC = MEM[MAR]; (addr)
                               pc_ce <= '1';
                               pc_ctrl <= PC_MEM_IN;
                             else
                               -- PC = PC + 1;
                               pc_ce <= '1';
                               mux_ctrl <= PC_IN;
                               alu_ctrl <= A_INC;
                             end if;
                             -- return to fetch1‚
                             timer_ctrl <= T_LOAD;
        
        -- bad instruction
        when others => mux_ctrl <= "---";
	               timer_ctrl <= T_LOAD;
      end case;
    end if;
  end process fsm_cu;


  timer_mux_reg : process(clk, reset)
  begin
    if reset = '1' then
      timer <= (others=>'0');
    elsif rising_edge(clk) then  
      case timer_ctrl is 
        when T_INC  => timer <= timer + '1';
        when T_LOAD => timer <= "00";
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
        case pc_ctrl is 
          when PC_ALU_IN => pc <= alu;
          when PC_MEM_IN => pc <= instruction;
        end case;
      end if;
    end if;
  end process pc_mux_reg;


  pc_out <= pc;
  addr <= mar;

  -- debug output
  timer_out <= timer;

end behv;

