library ieee;
use ieee.std_logic_1164.all;
use WORK.aes_package.all;


entity sbox is 
  port (
     data_in  : in std_logic_vector(127 downto 0);
     data_out : out std_logic_vector(127 downto 0)
    );     
end sbox;

architecture sbox_RTL of sbox is
begin

    sub_bytes : process(data_in)
    begin 
        for i in 16 downto 1 loop
            data_out( ((i * 8) - 1) downto ((i * 8) - 8) ) <= sbox_fun(data_in( ((i * 8) - 1) downto ((i * 8) - 8) ));
        end loop;    
    end process;
      
end sbox_RTL;
