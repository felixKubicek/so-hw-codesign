Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;
use work.lib.ALL;

entity core is
  PORT(
      clk       : IN std_logic;
      reset     : IN std_logic;
      reg0      : OUT TData;
      reg1      : OUT TData;
      reg2      : OUT TData;
      reg3      : OUT TData;
      reg2input : IN TData;
      reg3input : IN TData
      );
end core;

architecture behavior of core is

signal ld0_tmp, ld1_tmp, ld2_tmp, ld3_tmp : std_logic;
signal mux_ctrl_tmp : std_logic_vector(2 downto 0);
signal alu_ctrl_tmp : alu_mode;
signal pc_tmp : TProgAddr;
signal alu_tmp : TData;
signal Z_tmp : std_logic;

signal addrBus : TProgAddr;
signal dataBus : TInstruction;

begin	
  
  ControlPath : entity work.ctrlPath port map(
    clk         => clk,   
    reset       => reset,
    Zin         => Z_tmp,
    alu         => alu_tmp,
    pc_out      => pc_tmp,
    addr        => addrBus,
    instruction => dataBus,
    ld0         => ld0_tmp,
    ld1         => ld1_tmp,
    ld2         => ld2_tmp,
    ld3         => ld3_tmp,
    mux_ctrl    => mux_ctrl_tmp,
    alu_ctrl    => alu_ctrl_tmp
  );
  
  DataPath : entity work.ctrlPath port map(
    clk      => clk,  
    reset    => reset,
    ld0      => ld0_tmp,
    ld1      => ld1_tmp,
    ld2      => ld2_tmp,
    ld3      => ld3_tmp,
    mux_ctrl => mux_ctrl_tmp,
    alu_ctrl => alu_ctrl_tmp,
    r2in     => reg2input,
    r3in     => reg3input,
    pcin     => pc_tmp,
    r0out    => reg0,
    r1out    => reg1,
    r2out    => reg2,
    r3out    => reg3,
    alu      => alu_tmp,
    Zout     => Z_tmp
  );
  
  Memory : entity work.pMemory port map(
    reset       => reset,
    inAddr      => addrBus,
    instruction => dataBus
  );

end behavior;

