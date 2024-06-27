----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.02.2024 14:57:00
-- Design Name: 
-- Module Name: my_clk_divider_rl - Behavioral
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

entity my_clk_divider_rl is
    Port ( CLK100MHZ : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (0 downto 0));
end my_clk_divider_rl;

architecture Behavioural of my_clk_divider_rl is
signal a: STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";

begin
    inst_1 : entity work.my_clk_divider(Behavioural)
    port map (CLK => CLK100MHZ, SLOWCLK => LED(0), UPPERBOUND => a);
    
end Behavioural;