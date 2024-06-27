library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_mux is
    Port ( DISPLAY_SEL : in STD_LOGIC_VECTOR (2 downto 0);
           MESSAGE : in STD_LOGIC_VECTOR (31 downto 0);
           BCD : out STD_LOGIC_VECTOR (3 downto 0) := "0000";
           DP : out STD_LOGIC := '0');
end my_mux;

architecture Behavioural of my_mux is

signal bcd_temp: STD_LOGIC_VECTOR (3 downto 0) := "0000";
signal dp_temp: STD_LOGIC;

begin

--Special cases for the display to show the counting down decimial points.
muxing: process (MESSAGE, DISPLAY_SEL)
    begin
        dp_temp <= '0';
        if MESSAGE = "10000000000000000000000000000000" then -- Special message checked by the FSM, too high to be reasonably read hit by the user.
            if (DISPLAY_SEL = "000" or DISPLAY_SEL = "001" or DISPLAY_SEL = "010") then --If the display selector is one of the last three displays.
                dp_temp <= '1'; -- enables the decimal point for this display.
            end if;
        elsif MESSAGE = "11000000000000000000000000000000" then
            if (DISPLAY_SEL = "000" or DISPLAY_SEL = "001") then -- then the last 2
                dp_temp <= '1';
            end if;
        elsif MESSAGE = "11100000000000000000000000000000" then -- then the last display.
            if (DISPLAY_SEL = "000") then
                dp_temp <= '1';
            end if;    
        end if;

    end process;
    DP <= dp_temp;

--If the message is not one of the special cases then set the 4 bit display selector message to the relevent 4 bits from the message.
--E.g the first 4 bits from the message will be displayed on the left most seven segment display.
muxing_2: process (MESSAGE, DISPLAY_SEL)
    begin
        if (MESSAGE /= "11100000000000000000000000000000" and MESSAGE /= "11000000000000000000000000000000" and MESSAGE /= "10000000000000000000000000000000") then
            case (DISPLAY_SEL) is
                when "000" => bcd_temp <= MESSAGE(3 downto 0); -- left most seven segment display (last display)
                when "001" => bcd_temp <= MESSAGE(7 downto 4);
                when "010" => bcd_temp <= MESSAGE(11 downto 8);
                when "011" => bcd_temp <= MESSAGE(15 downto 12);
                when "100" => bcd_temp <= MESSAGE(19 downto 16);
                when "101" => bcd_temp <= MESSAGE(23 downto 20);
                when "110" => bcd_temp <= MESSAGE(27 downto 24);
                when "111" => bcd_temp <= MESSAGE(31 downto 28); -- right most seven segment display.
                when others => bcd_temp <= "0000";
            end case;
        else             
            bcd_temp <= "1010";
        end if;
    end process;
    BCD <= bcd_temp;

end Behavioural;
