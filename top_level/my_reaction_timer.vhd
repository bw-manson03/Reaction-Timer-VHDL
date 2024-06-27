library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_reaction_timer is
    Port ( CLK100MHZ : in STD_LOGIC;
           BTNC : in STD_LOGIC;
           BTNL : in STD_LOGIC;
           BTNR : in STD_LOGIC;
           BTNU : in STD_LOGIC;
           BTND : in STD_LOGIC;
           AN : out STD_LOGIC_VECTOR (7 downto 0);
           CA : out STD_LOGIC_VECTOR (7 downto 0));
           
end my_reaction_timer;

architecture Behavioural of my_reaction_timer is

--Slow clock signals for the display and the finite state machine.
signal display_clk_sig : STD_LOGIC;
signal FSM_clk : STD_LOGIC;

--Timer upperbounds for each of the clock dividers.
signal upperbound_disp : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000111110100000";
signal upperbound_FSM : STD_LOGIC_VECTOR (31 downto 0) :=  "00000000000000001100001101010000";

signal count_rst_FSM : STD_LOGIC;
signal count_en_FSM : STD_LOGIC;
signal message_FSM : STD_LOGIC_VECTOR (31 downto 0);

--Values for each of the timer counts ranging from 0 to 9.
signal count_1_FSM : STD_LOGIC_VECTOR (3 downto 0);
signal count_2_FSM : STD_LOGIC_VECTOR (3 downto 0);
signal count_3_FSM : STD_LOGIC_VECTOR (3 downto 0);
signal count_4_FSM : STD_LOGIC_VECTOR (3 downto 0);
signal count_5_FSM : STD_LOGIC_VECTOR (3 downto 0);
signal count_6_FSM : STD_LOGIC_VECTOR (3 downto 0);
signal count_7_FSM : STD_LOGIC_VECTOR (3 downto 0);
signal count_8_FSM : STD_LOGIC_VECTOR (3 downto 0);

--Increment signals for each of the counters for the reaction time.
signal tick_1 : STD_LOGIC;
signal tick_2 : STD_LOGIC;
signal tick_3 : STD_LOGIC;
signal tick_4 : STD_LOGIC;
signal tick_5 : STD_LOGIC;
signal tick_6 : STD_LOGIC;
signal tick_7 : STD_LOGIC;
signal tick_8 : STD_LOGIC;

signal current_disp : STD_LOGIC_VECTOR (2 downto 0) := "000";

signal segment_signal : STD_LOGIC_VECTOR (3 downto 0) := "0000";
signal segment_dp : STD_LOGIC;

signal circ_buf_rst : STD_LOGIC;

--Write enable in and out to activate the circular buffer and recorded a timer value.
signal write_en_out : STD_LOGIC;
signal write_en_in : STD_LOGIC;

--Recorded signals from the circular buffer outputting the signals to the display.
signal average_time : STD_LOGIC_VECTOR (31 downto 0);
signal best_time : std_logic_vector(31 downto 0);
signal worst_time : std_logic_vector(31 downto 0);

--Aggregate value of all of the timing counters
--Shown on the display, and recorded into the circular buffer.
signal recorded : STD_LOGIC_VECTOR (31 downto 0);

--Random number generated from the psuedo random number generator.
signal random_int : STD_LOGIC_VECTOR(9 downto 0);

--Enables or disables the psuedo random number generator.
signal stop_random : STD_LOGIC;


begin
    inst_my_clk_divider_disp : entity work.my_clk_divider(Behavioural)
        port map (CLK => CLK100MHZ, UPPERBOUND => upperbound_disp, SLOWCLK => display_clk_sig);
    
    inst_my_display_sel : entity work.my_display_sel(Behavioural)
        port map (DISPLAY_CLK => display_clk_sig, CURRENT_DISPLAY => current_disp);
    
    inst_my_clk_divider_FSM : entity work.my_clk_divider(Behavioural)
        port map (CLK => CLK100MHZ, UPPERBOUND => upperbound_FSM, SLOWCLK => FSM_clk);
    
    inst_my_FSM : entity work.my_FSM(Behavioural)
        port map (MESSAGE => message_FSM, BTNC => BTNC, BTNL => BTNL, BTNR => BTNR, BTNU => BTNU, BTND => BTND, 
        CLK => FSM_clk, COUNT_RST => count_rst_FSM, COUNT_EN => count_en_FSM, COUNT_1 => count_1_FSM, COUNT_2 => count_2_FSM, 
        COUNT_3 => count_3_FSM, COUNT_4 => count_4_FSM, COUNT_5 => count_5_FSM, COUNT_6 => count_6_FSM, COUNT_7 => count_7_FSM, 
        COUNT_8 => count_8_FSM, BEST_TIME => best_time, WORST_TIME => worst_time, AVERAGE_TIME => average_time,
        CIRC_BUF_RST => circ_buf_rst, RECORDED => recorded, WRITE_EN => write_en_out, RANDOM_IN => random_int, STOP => stop_random);
    
    inst_my_reset_counter_1 : entity work.my_reset_counter(Behavioural)
        port map (EN => count_en_FSM, RESET => count_rst_FSM, INCREMENT => FSM_clk, COUNT => count_1_FSM, TICK => tick_1);
    
    inst_my_reset_counter_2 : entity work.my_reset_counter(Behavioural)
        port map (EN => count_en_FSM, RESET => count_rst_FSM, INCREMENT => tick_1, COUNT => count_2_FSM, TICK => tick_2);
    
    inst_my_reset_counter_3 : entity work.my_reset_counter(Behavioural)
        port map (EN => count_en_FSM, RESET => count_rst_FSM, INCREMENT => tick_2, COUNT => count_3_FSM, TICK => tick_3);
        
    inst_my_reset_counter_4 : entity work.my_reset_counter(Behavioural)
        port map (EN => count_en_FSM, RESET => count_rst_FSM, INCREMENT => tick_3, COUNT => count_4_FSM, TICK => tick_4);
        
    inst_my_reset_counter_5 : entity work.my_reset_counter(Behavioural)
        port map (EN => count_en_FSM, RESET => count_rst_FSM, INCREMENT => tick_4, COUNT => count_5_FSM, TICK => tick_5);
        
    inst_my_reset_counter_6 : entity work.my_reset_counter(Behavioural)
        port map (EN => count_en_FSM, RESET => count_rst_FSM, INCREMENT => tick_5, COUNT => count_6_FSM, TICK => tick_6);
    
    inst_my_reset_counter_7 : entity work.my_reset_counter(Behavioural)
        port map (EN => count_en_FSM, RESET => count_rst_FSM, INCREMENT => tick_6, COUNT => count_7_FSM, TICK => tick_7);
        
    inst_my_reset_counter_8 : entity work.my_reset_counter(Behavioural)
        port map (EN => count_en_FSM, RESET => count_rst_FSM, INCREMENT => tick_7, COUNT => count_8_FSM, TICK => tick_8);
        
    inst_my_anode_decoder : entity work.my_anode_decoder(Behavioural)
        port map (DISPLAY_SELECTED => current_disp, ANODE => AN);
        
    inst_my_mux : entity work.my_mux(Behavioural)
        port map (DISPLAY_SEL => current_disp, MESSAGE => message_FSM, BCD => segment_signal, DP => segment_dp);
        
    inst_bcd_to_7seg : entity work.bcd_to_7seg(Behavioural)
        port map (BCD => segment_signal, DP => segment_dp, SEG => CA);
        
    inst_my_circular_buffer : entity work.my_circular_buffer(Behavioural)
        port map (CLK => display_clk_sig, RESET => circ_buf_rst, RECORDED => recorded, WRITE_EN_IN => write_en_out,
        AVERAGE_TIME => average_time, BEST_TIME => best_time, WORST_TIME => worst_time);
    
    inst_my_PRNG : entity work.my_PRNG(Behavioural)
        port map (CLK => CLK100MHZ, RST => circ_buf_rst, RANDOM_OUT => random_int, STOP => stop_random, RECORDED => recorded);

end Behavioural;
