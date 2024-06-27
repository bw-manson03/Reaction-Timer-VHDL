library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity my_reset_counter is
    Port ( EN : in STD_LOGIC;
           RESET : in STD_LOGIC;
           INCREMENT : in STD_LOGIC;
           TICK : out STD_LOGIC;
           COUNT : out STD_LOGIC_VECTOR (3 downto 0));
end my_reset_counter;

architecture Behavioural of my_reset_counter is

signal en_latch: STD_LOGIC := '0';
signal count_1: STD_LOGIC_VECTOR (3 downto 0):= "0000";
signal tick_1: STD_LOGIC := '0';    

begin
    process(EN, RESET, INCREMENT, en_latch, count_1, tick_1)
        begin
            if EN = '1' then
                if rising_edge(INCREMENT) then
                    count_1 <= std_logic_vector(unsigned(count_1) + 1);
                    if RESET = '1' then
                        count_1 <= "0000";
                    end if;
                    --If the counter is 9, then the next place value needs to be incremented, setting the increment tick to 1.
                    --And this place value needs to be set to zero.
                     if count_1 = "1001" then 
                        count_1 <= "0000";
                        tick_1 <= '1';
                     else
                        tick_1 <= '0';
                    end if;
                end if;
            end if;
            --If the counter is being reset then the count is reset
            if RESET = '1' then
                count_1 <= "0000";
            end if; 
            --Update the COUNT and TICK reguardless of enable state.
            COUNT <= count_1;
            TICK <= tick_1;
    end process;

end Behavioural;
