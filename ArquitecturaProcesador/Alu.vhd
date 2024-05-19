-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity ALU is
port(
  A: in std_logic_vector(31 downto 0);
  B: in std_logic_vector(31 downto 0);
  ctrl: in std_logic_vector(2 downto 0);
  result: out std_logic_vector(31 downto 0);
  zero: out std_logic;
  );
end ALU;

architecture rtl of ALU is
signal alu_result: std_logic_vector(31 downto 0);
begin
    process(A, B, ctrl)
    begin
    	if (ctrl = "000") then
        	alu_result <= A and B;
        elsif (ctrl = "001") then
        	alu_result <= A or B;
        elsif (ctrl = "010") then
        	alu_result <= A + B;
        elsif (ctrl = "110") then
        	alu_result <= A - B;
        elsif (ctrl = "111") then
        	if (A < B) then
            	alu_result <= x"00000001";
            else
            	alu_result <= x"00000000";
            end if;
        elsif (ctrl = "100") then
        	alu_result <= B(15 downto 0) & x"0000";
        else
        	alu_result <= x"00000000";
        end if;
    end process;
    result <= alu_result;
    zero <= '1' when alu_result = x"00000000" else '0';
end rtl;
