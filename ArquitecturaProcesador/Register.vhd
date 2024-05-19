-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.ALL;


entity RegMem is
port(
  clk: in std_logic;
  reset: in std_logic;
  wr: in std_logic;
  reg1_rd: in std_logic_vector(4 downto 0);
  reg2_rd: in std_logic_vector(4 downto 0);
  reg_wr: in std_logic_vector(4 downto 0);
  data_wr: in std_logic_vector(31 downto 0);
  data1_rd: out std_logic_vector(31 downto 0);
  data2_rd: out std_logic_vector(31 downto 0)
  );
end RegMem;

architecture rtl of RegMem is
type mem is array(31 downto 0) of std_logic_vector(31 downto 0);
signal reg: mem;
begin
	process(clk, reset)
    begin
    	if (reset = '1') then
        	reg <= (others => x"00000000");
        elsif (falling_edge(clk)) then
        	if (wr = '1') then
            	reg(to_integer(unsigned(reg_wr))) <= data_wr;
            end if;
        end if;
    end process;
    
    data1_rd <= reg(to_integer(unsigned(reg1_rd))) when reg1_rd /= "00000" else x"00000000";
    data2_rd <= reg(to_integer(unsigned(reg2_rd))) when reg2_rd /= "00000" else x"00000000";
end rtl;
