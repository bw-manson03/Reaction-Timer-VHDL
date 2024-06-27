library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity my_FSM is
    Port ( BTNC : in STD_LOGIC;
           BTNL : in STD_LOGIC;
           BTNR : in STD_LOGIC;
           BTNU : in STD_LOGIC;
           BTND : in STD_LOGIC;
           CLK: in STD_LOGIC;
           COUNT_1, COUNT_2, COUNT_3, COUNT_4, COUNT_5, COUNT_6, COUNT_7, COUNT_8 : in STD_LOGIC_VECTOR (3 downto 0);
           MESSAGE : out STD_LOGIC_VECTOR (31 downto 0) := "10000000000000000000000000000000";
           COUNT_EN, COUNT_RST : out STD_LOGIC;
           BEST_TIME : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           WORST_TIME : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           AVERAGE_TIME : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           CIRC_BUF_RST : out STD_LOGIC;
           RECORDED : out STD_LOGIC_VECTOR (31 downto 0):= "00000000000000000000000000000000";
           WRITE_EN : out STD_LOGIC := '0';
           RANDOM_IN : in STD_LOGIC_VECTOR (9 downto 0);
           STOP : out STD_LOGIC := '0');
end my_FSM;

architecture Behavioural of my_FSM is

    type state_type is (WARNING_3, WARNING_2, WARNING_1, COUNTING, PRINT_CURRENT, PRINT_AVG, PRINT_BEST, PRINT_WORST, ERROR);
    signal current_state, next_state : state_type := WARNING_3;
    constant T1: integer := 499;
    signal t: integer range 0 to 99999;
    signal rst: STD_LOGIC := '1';
    signal temp_mess: STD_LOGIC_VECTOR (31 downto 0);
    signal is_written: std_logic := '0';
    signal random_set_3: std_logic := '0';
    signal random_set_2: std_logic := '0';
    signal random_set_1: std_logic := '0';
    signal T_WARN_3 : integer;
    signal T_WARN_2 : integer;
    signal T_WARN_1 : integer;


begin

--Continuously updates the state, and sets the state back to the first warning on reset.
STATE_REGISTER: process (CLK, RST)
    begin   
        if (rising_edge(CLK)) then
            if (rst = '1') then
                current_state <= WARNING_3;
                rst <= '0';
            else
                current_state <= next_state;
            end if;
        end if;
    end process;
    
--Updates the message and variables based on the current state
OUTPUT_DECODE: process (clk)
    begin
        case (current_state) is
            when WARNING_3 => 
                COUNT_EN <= '0'; 
                COUNT_RST <= '1'; -- Reset the counter for a new test run.
                temp_mess <= "10000000000000000000000000000000"; -- Set the message to display decimal points on the three right most displays.
            when WARNING_2 =>
                COUNT_EN <= '0';
                COUNT_RST <= '0';
                temp_mess <= "11000000000000000000000000000000"; -- Set the message to display decimal points on the two right most displays.
            when WARNING_1 =>
                COUNT_EN <= '0';
                COUNT_RST <= '0';
                temp_mess <= "11100000000000000000000000000000"; -- Set the message to display a decimal point on the right most display.
            when COUNTING =>
                COUNT_EN <= '1'; -- enable the counters to measure the time taken
                COUNT_RST <= '0';
                temp_mess(31 downto 0) <= COUNT_8 & COUNT_7 & COUNT_6 & COUNT_5 & COUNT_4 & COUNT_3 & COUNT_2 & COUNT_1; --Display the current time on the displays
                RECORDED(31 downto 0) <= temp_mess; -- update the outputted recorded message with the current time for the test run.
            when PRINT_CURRENT =>
                COUNT_EN <= '0'; -- Disable counting now the middle button has been pressed.
                COUNT_RST <= '0';
                temp_mess(31 downto 0) <= COUNT_8 & COUNT_7 & COUNT_6 & COUNT_5 & COUNT_4 & COUNT_3 & COUNT_2 & COUNT_1;
                RECORDED(31 downto 0) <= temp_mess;
            when PRINT_AVG =>
                COUNT_EN <= '0';
                COUNT_RST <= '0';
                temp_mess(27 downto 0) <= AVERAGE_TIME(27 downto 0); --Display the average time
                temp_mess(31 downto 28) <= "1100"; --Set the left most display to show an "A".
            when PRINT_BEST =>
                COUNT_EN <= '0';
                COUNT_RST <= '0';
                temp_mess(27 downto 0) <= BEST_TIME(27 downto 0);--Display the lowest recorded time
                temp_mess(31 downto 28) <= "1101";  --Set the left most display to show an "L".
            when PRINT_WORST =>
                COUNT_EN <= '0';
                COUNT_RST <= '0';
                temp_mess(27 downto 0) <= WORST_TIME(27 downto 0); --Display the highest recorded time
                temp_mess(31 downto 28) <= "1011";  --Set the left most display to show an "H".
            when ERROR =>
                COUNT_EN <= '0';
                COUNT_RST <= '0';
                temp_mess(19 downto 0) <= "10101010101010101010"; --Set the message to display nothing for the bottom 5 displays
                temp_mess(31 downto 20) <= "111111101110"; -- Display "Err" on the three left most displays.
            when others =>
                COUNT_EN <= '0';
                COUNT_RST <= '1';
                temp_mess <= X"00000000"; -- Force to 0 on unknown state.
        end case;
    end process;  
    MESSAGE <= temp_mess; -- Continuously update the message
   
 --Determine the next state based on button inputs and current state
NEXT_STATE_DECODE: process (CLK, current_state, t, BTNC, BTNR, BTNU, BTND, BTNL)
    begin
        if rising_edge(CLK) then
            if random_set_3 = '1' then -- If all three random numbers have been set.
                case (current_state) is
                    when WARNING_3 =>
                        if t = T_WARN_3 - 1 then 
                            next_state <= WARNING_2; -- If sufficent time has passed since starting then go to the next warning state to continue counting down.
                        else
                            next_state <= WARNING_3;
                        end if;
                    when WARNING_2 =>
                        if t = T_WARN_2 - 1 then --Similarly, wait for sufficent time until swapping to WARNING_1.
                            next_state <= WARNING_1;
                        elsif BTNC = '1' then -- If the centre button is pressed too early in WARNING_2 or WARNING_1 display go to the ERROR state and display an error message.
                            next_state <= ERROR;
                        else
                            next_state <= WARNING_2;
                        end if;
                    when WARNING_1 =>
                        if t = T_WARN_1 - 1 then
                            next_state <= COUNTING; -- Go to the counting state after all warning states are completed.
                        elsif BTNC = '1' then -- centre button pressed too early.
                            next_state <= ERROR;
                        else
                            next_state <= WARNING_1;
                        end if;
                    when COUNTING =>
                        if BTNC = '1' then
                            next_state <= PRINT_CURRENT; -- When the centre button has been pressed go to Print current, and record the timed value.
                        end if;
                    when ERROR =>
                        if t = T1 - 1 then -- Wait for the error message to be displayed for sufficent time before advancing back to the start (WARNING_3).
                            next_state <= WARNING_3;
                        end if;
                    when others => -- Otherwise update the next state and listen for button presses.
                        next_state <= current_state;
                        if BTNC = '1' and t >= T1-2 then next_state <= WARNING_3; end if; -- Start a new reaction test, after a set time has elapsed to display the recorded time.
                        if BTNR = '1' then next_state <= PRINT_AVG; end if; -- Display the average score
                        if BTND = '1' then next_state <= PRINT_WORST; end if; -- Display the worst score
                        if BTNU = '1' then next_state <= PRINT_BEST; end if; -- Display the best score
                        if BTNL = '1' then CIRC_BUF_RST <= '1'; end if; -- Send a signal to reset the buffer while the left button is pressed.
                        if BTNL = '0' then CIRC_BUF_RST <= '0'; end if;
                end case;
            end if;
        end if;
    end process;
    
-- Sets the random times for the warning states.
-- Checks if each warning random time has been set
-- If it hasn't, set it.
RANDOM_TIME: process (CLK, RANDOM_IN)
begin
    if rising_edge(clk) then
        if random_set_3 = '0' then
            T_WARN_3 <= to_integer(unsigned(RANDOM_IN));
            random_set_3 <= '1';
        elsif random_set_3 = '1' and random_set_2 = '0' then
            T_WARN_2 <= to_integer(unsigned(RANDOM_IN));
            random_set_2 <= '1';
        elsif random_set_3 = '1' and random_set_2 = '1' and random_set_1 = '0' then
            T_WARN_1 <= to_integer(unsigned(RANDOM_IN));
            random_set_1 <= '1';
            STOP <= '1';
        end if;
        
        --Generate new random times for each warning state.
        if current_state = COUNTING and next_state = PRINT_CURRENT then
            STOP <= '0';
            random_set_3 <= '0';
            random_set_2 <= '0';
            random_set_1 <= '0';
        end if;
    end if;
end process;

-- Enable writing to the buffer when a test has been completed.
WRITE_EN_PROCESS: process (next_state)
begin
    if current_state = COUNTING and next_state = PRINT_CURRENT then
        WRITE_EN <= '1';
    else
        WRITE_EN <= '0';
    end if;
end process;
    
--Increments the timer t, for each state, and resets it at the end of each state.
TIMER: process (CLK)
    begin
        if rising_edge(CLK) then
            if current_state /= next_state then
                if current_state /= PRINT_WORST and current_state /= PRINT_AVG and current_state /= PRINT_BEST then 
                    t <= 0;
                end if;
            else
                if current_state = WARNING_3 then
                    if t < T_WARN_3 - 1 then
                        t <= t + 1;
                    end if;
                elsif current_state = WARNING_2 then
                    if t < T_WARN_2 - 1 then
                        t <= t + 1;
                    end if; 
                elsif current_state = WARNING_1 then
                    if t < T_WARN_1 - 1 then
                        t <= t + 1;
                    end if; 
                else
                    if t < T1 - 1 then
                        t <= t + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
                
end Behavioural;
