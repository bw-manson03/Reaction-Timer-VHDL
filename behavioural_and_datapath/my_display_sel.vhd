library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity my_display_sel is
    Port ( DISPLAY_CLK : in STD_LOGIC;
           CURRENT_DISPLAY : out STD_LOGIC_VECTOR (2 downto 0) := "000");
end my_display_sel;

architecture Behavioural of my_display_sel is

signal counter1: STD_LOGIC_VECTOR (3 downto 0) := "0000";

--Loops through each seven segment display and selects each display with a counter.
begin
    segment_clk: process (DISPLAY_CLK, counter1) is
        begin
            if rising_edge (DISPLAY_CLK) then
                if counter1 = "1000" then -- reset the counter when it gets to 8 and loops around to the left most display.
                    counter1 <= "0000";
                else
                    counter1 <= std_logic_vector(unsigned(counter1) + 1);
                end if;
            end if;            
    end process;
    CURRENT_DISPLAY <= counter1 (2 downto 0);
end Behavioural;
