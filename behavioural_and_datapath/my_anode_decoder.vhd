----------------------------------------------------------------------------------
-- Company: bEANS inC
-- Engineer: 
-- 
-- Create Date: 02.03.2024 11:21:15
-- Design Name: 
-- Module Name: my_anode_decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity my_anode_decoder is
    Port ( DISPLAY_SELECTED : in STD_LOGIC_VECTOR (2 downto 0);
           ANODE : out STD_LOGIC_VECTOR (7 downto 0));
end my_anode_decoder;

architecture Behavioural of my_anode_decoder is

--Converts a numerical value from 0 to 7 to select a specific seven segment display to output to.
begin 
    node_decoder: process(DISPLAY_SELECTED) is
    begin
        
        case (DISPLAY_SELECTED) is
            when "000" => ANODE <= "11111110"; -- left most display.
            when "001" => ANODE <= "11111101";
            when "010" => ANODE <= "11111011";
            when "011" => ANODE <= "11110111";
            when "100" => ANODE <= "11101111";
            when "101" => ANODE <= "11011111";
            when "110" => ANODE <= "10111111";
            when "111" => ANODE <= "01111111"; -- right most display.
            when others => NULL;
         end case;
    end process;
    
end Behavioural;
