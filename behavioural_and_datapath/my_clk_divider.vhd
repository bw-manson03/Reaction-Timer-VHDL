library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity my_clk_divider is
    Port ( CLK : STD_LOGIC;
           UPPERBOUND : in STD_LOGIC_VECTOR (31 downto 0);
           SLOWCLK : out STD_LOGIC);
end my_clk_divider;

architecture Behavioural of my_clk_divider is

signal counter1: INTEGER := 0;
signal temp1: std_logic := '0';

begin

    clk_div: process (CLK) is
    begin  
        if rising_edge (CLK) then
            --If the local upperbound value on the counter has been reached then switch the clock signal.
            if counter1 = unsigned(UPPERBOUND) then
                temp1 <= NOT temp1;
                counter1 <= 0;
            else
                counter1 <= counter1 + 1;
            end if;    
        end if;
    end process clk_div;  
       
    SLOWCLK <= temp1;  
    
end Behavioural;
