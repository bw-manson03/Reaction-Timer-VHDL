library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_switch_encoder is
    Port ( SW : in std_logic_vector(15 downto 0)
           #_OF_READINGS : out (15 downto 0));
           
end my_switch_encoder;

architecture Behavioural of my_switch_encoder is

signal temp1 : std_logic_vector(15 downto 0);

begin
    temp1 <= SW;
    #_OF_READINGS <= temp1;

end Behavioural;