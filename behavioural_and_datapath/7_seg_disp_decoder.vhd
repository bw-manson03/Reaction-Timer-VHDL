-------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineer: Ciaran Moore
-------------------------------------------------------------------------------
--Inputs a numerical bcd value and outputs a specific encoded value to be displayed on a seven segment display

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_to_7seg is
    port ( bcd : in STD_LOGIC_VECTOR (3 downto 0) := "0000";
        dp : in STD_LOGIC;
        seg : out STD_LOGIC_VECTOR (0 to 7));
    end bcd_to_7seg;
architecture Behavioural of bcd_to_7seg is

begin
    process (bcd) is
        begin
            case (bcd) is
                when "0000" => seg(0 to 6) <= not "1111110"; -- 0
                when "0001" => seg(0 to 6) <= not "0110000"; -- 1
                when "0010" => seg(0 to 6) <= not "1101101"; -- 2
                when "0011" => seg(0 to 6) <= not "1111001"; -- 3
                when "0100" => seg(0 to 6) <= not "0110011"; -- 4
                when "0101" => seg(0 to 6) <= not "1011011"; -- 5
                when "0110" => seg(0 to 6) <= not "1011111"; -- 6
                when "0111" => seg(0 to 6) <= not "1110000"; -- 7
                when "1000" => seg(0 to 6) <= not "1111111"; -- 8
                when "1001" => seg(0 to 6) <= not "1110011"; -- 9
                when "1010" => seg(0 to 6) <= not "0000000"; -- blank
                when "1011" => seg(0 to 6) <= not "0110111"; -- H
                when "1100" => seg(0 to 6) <= not "1110111"; -- A
                when "1101" => seg(0 to 6) <= not "0001110"; -- L
                when "1111" => seg(0 to 6) <= not "1001111"; -- E
                when "1110" => seg(0 to 6) <= not "0000101"; -- r
                when others => NULL;
            end case;
    end process;
    seg(7) <= not dp;
end Behavioural;