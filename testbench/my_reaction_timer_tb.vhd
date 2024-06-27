library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_reaction_timer_tb is
--  Port ( );
end my_reaction_timer_tb;

architecture Behavioural of my_reaction_timer_tb is

signal CLK100MHZ : STD_LOGIC := '0';
signal BTNC : STD_LOGIC := '0';
signal BTNL : STD_LOGIC := '0';
signal BTNR : STD_LOGIC := '0';
signal BTNU : STD_LOGIC := '0';
signal BTND : STD_LOGIC := '0';
signal AN : STD_LOGIC_VECTOR (7 downto 0);
signal CA : STD_LOGIC_VECTOR (7 downto 0);

begin

inst_my_reaction_timer : entity work.my_reaction_timer(Behavioural)
port map (CLK100MHZ => CLK100MHZ, BTNC => BTNC, BTNL => BTNL, BTNR => BTNR, BTNU => BTNU, BTND => BTND, AN => AN, CA => CA);

clock: process
    begin
        wait for 10ns;
        CLK100MHZ <= NOT CLK100MHZ;
        wait for 10ns;
        CLK100MHZ <= NOT CLK100MHZ;
    end process;

button_press: process
    begin
        wait for 3870ms;
        BTNC <= NOT BTNC;
        wait for 5ms;
        BTNC <= NOT BTNC;
        wait for 500ms;
        BTNR <= NOT BTNR;
        wait for 5ms;
        BTNR <= NOT BTNR;
        wait for 5ms;
        BTNU <= NOT BTNU;
        wait for 5ms;
        BTNU <= NOT BTNU;
        wait for 5ms;
        BTND <= NOT BTND;
        wait for 5ms;
        BTND <= NOT BTND;
        wait for 500ms;
        BTNC <= NOT BTNC;
        wait for 5ms;
        BTNC <= NOT BTNC;
        wait for 1000ms;
    end process;

end Behavioural;
