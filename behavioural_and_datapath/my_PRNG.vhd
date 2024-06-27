library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity my_PRNG is
    generic (
        SEED_WIDTH : integer := 10
    );
    Port (
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        RANDOM_OUT : out STD_LOGIC_VECTOR (SEED_WIDTH-1 downto 0);
        STOP : in STD_LOGIC;
        RECORDED : in STD_LOGIC_VECTOR (31 downto 0)
    );
end my_PRNG;

architecture Behavioural of my_PRNG is
    signal lfsr : std_logic_vector(SEED_WIDTH-1 downto 0) := (others => '1');
    signal scaled_random : unsigned(SEED_WIDTH-1 downto 0);
    constant MIN_VALUE : natural := 299;
    constant MAX_VALUE : natural := 1999;
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            lfsr <= (others => '1'); -- Reset LFSR
        elsif rising_edge(CLK) then
            if STOP = '0' then -- If the pseudo random number generator is not disabled.
                for i in 0 to SEED_WIDTH-1 loop
                    lfsr(i) <= lfsr(i) xor RECORDED(i mod 32);
                end loop;
                
                -- LFSR feedback
                lfsr(0) <= lfsr(SEED_WIDTH-2) xor lfsr(SEED_WIDTH-1);
                lfsr(SEED_WIDTH-1 downto 1) <= lfsr(SEED_WIDTH-2 downto 0);
                
                -- Scale down the random number to desired range
                scaled_random <= to_unsigned(MIN_VALUE, SEED_WIDTH) +
                                 to_unsigned(to_integer(unsigned(lfsr)) mod (MAX_VALUE - MIN_VALUE + 1), SEED_WIDTH);
                RANDOM_OUT <= std_logic_vector(scaled_random);
            end if;
        end if;
    end process;

end Behavioural;
