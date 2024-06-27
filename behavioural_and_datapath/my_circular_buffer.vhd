library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity my_circular_buffer is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           RECORDED : in STD_LOGIC_VECTOR (31 downto 0) := "10101001001010010010010000100101";
           WRITE_EN_IN : in STD_LOGIC;                      
           AVERAGE_TIME : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           BEST_TIME : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           WORST_TIME : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'));
end my_circular_buffer;

architecture Behavioural of my_circular_buffer is
    type CircBuffer is array (0 to 2) of std_logic_vector(31 downto 0);
    signal circ_buffer : CircBuffer;
    signal write_pointer : integer range 0 to 2 := 0;
    signal write_en : std_logic := '0';
    signal sum : std_logic_vector(31 downto 0) := (others => '0');
    signal count : std_logic_vector(31 downto 0) := (others => '0');
    signal average : std_logic_vector(31 downto 0) := (others => '0');
    signal best : std_logic_vector(31 downto 0) := (others => '1');
    signal worst : std_logic_vector(31 downto 0) := (others => '0');
    signal zero : std_logic_vector(31 downto 0) := (others => '0');
    signal actual_best : std_logic_vector(31 downto 0);
    signal actual_worst : std_logic_vector(31 downto 0);
    
    function calculate_new_min_value(circ_buffer : in CircBuffer;
                                     zero : in std_logic_vector(31 downto 0);
                                     data_out : std_logic_vector(31 downto 0);
                                     data_in : std_logic_vector(31 downto 0))
                                     return std_logic_vector is 
        variable min_val : std_logic_vector(31 downto 0) := data_in;
    begin
        for i in 0 to 2 loop
            if circ_buffer(i) /= zero then
                if circ_buffer(i) < min_val and circ_buffer(i) /= data_out then
                    
                    min_val := circ_buffer(i);
                end if;
            end if;
        end loop;
        return min_val;
    end calculate_new_min_value; 
    
    function calculate_new_max_value(circ_buffer : in CircBuffer; data_out : std_logic_vector(31 downto 0); data_in : std_logic_vector(31 downto 0)) return std_logic_vector is 
        variable max_val : std_logic_vector(31 downto 0) := data_in;
    begin
        for i in 0 to 2 loop
            if circ_buffer(i) > max_val and circ_buffer(i) /= data_out then
                max_val := circ_buffer(i);
            end if;
        end loop;
        return max_val;
    end calculate_new_max_value; 
    
    --ALU Function for calculating statistics.
    function alu_arithmetic(A : in std_logic_vector(31 downto 0); 
                            B : in std_logic_vector(31 downto 0);
                            opcode : in std_logic_vector(1 downto 0))
                            return std_logic_vector is
        variable temp_result : std_logic_vector(31 downto 0);
        variable temp_quotient : std_logic_vector(31 downto 0);
        variable temp_remainder : std_logic_vector(31 downto 0);
        variable carry : std_logic := '0';
        variable zero_sig : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
        variable Result : std_logic_vector(31 downto 0);
        variable Zero_out : std_logic;
        variable Overflow : std_logic;
    begin
        case Opcode is
            when "00" =>  -- Addition
                temp_result := (others => '0');
                carry := '0';
                for i in 0 to 31 loop
                    temp_result(i) := (A(i) and B(i)) or ((A(i) or B(i)) and not carry);
                    carry := (A(i) and B(i)) or (A(i) and carry) or (B(i) and carry);
                end loop;
                Result := temp_result;
                if temp_result = zero_sig then
                        Zero_out := '1'; 
                    else 
                        Zero_out := '0'; -- Output '1' if result is zero
                    end if;
            when "01" =>  -- Subtraction (using two's complement)
                temp_result := (others => '0');
                carry := '1';
                for i in 0 to 31 loop
                    temp_result(i) := (A(i) and not B(i)) or (not A(i) and B(i)) or ((not A(i) and B(i)) and not carry);
                    carry := (not A(i) and B(i)) or (not A(i) and carry) or (B(i) and carry);
                end loop;
                Result := temp_result;
                if temp_result = zero_sig then
                        Zero_out := '1'; 
                    else 
                        Zero_out := '0'; -- Output '1' if result is zero
                    end if;
            when "10" =>  -- Multiplication
                temp_result := (others => '0');
                for i in 0 to 31 loop
                    for j in 0 to 31 loop
                        if (i+j) < 32 then
                            temp_result(i+j) := temp_result(i+j) or (A(i) and B(j));
                        end if;
                    end loop;
                end loop;
                Result := temp_result;
                Overflow := '0'; -- No overflow check for multiplication
                if temp_result = zero_sig then
                        Zero_out := '1'; 
                    else 
                        Zero_out := '0'; -- Output '1' if result is zero
                    end if;
            when "11" =>  -- Division
                if B = zero_sig then
                    Result := (others => 'X');  -- Division by zero result
                    Overflow := '0'; -- No overflow check for division by zero
                    Zero_out := 'X'; -- Zero flag undefined for division by zero
                else
                    temp_quotient := (others => '0');
                    temp_remainder := A;
                    for i in 31 downto 0 loop
                        temp_remainder := temp_remainder(30 downto 0) & '0';
                        if temp_remainder >= B then
                            for i in 0 to 31 loop
                                temp_remainder(i) := (temp_remainder(i) and not B(i)) or (not temp_remainder(i) and B(i)) or ((not temp_remainder(i) and B(i)) and not carry);
                            end loop;
                            temp_quotient(i) := '1';
                        end if;
                    end loop;
                    Result := temp_quotient;
                    Overflow := '0'; -- No overflow check for division
                    if temp_result = zero_sig then
                        Zero_out := '1'; 
                    else 
                        Zero_out := '0'; -- Output '1' if result is zero
                    end if;
                end if;
            when others => 
                Result := (others => 'X');  -- Undefined operation
                Overflow := 'X';  -- Undefined operation
                Zero_out := 'X';  -- Undefined operation
        end case;
        return Result;
end function;

begin
process (CLK, RESET)
    variable data_out : std_logic_vector(31 downto 0);
    variable data_in : std_logic_vector(31 downto 0);
    variable temp_count : std_logic_vector(31 downto 0);
    begin 
        if rising_edge(CLK) then --Synchronize with the clock.
            if reset = '1' then --When resetting the circular buffer, set all values in the buffer to zero
                circ_buffer <= (others => (others => '0'));
                write_pointer <= 0;
                sum <= (others => '0');
                temp_count := (others => '0');
                best <= (others => '0');
                worst <= (others => '0');
        
            elsif WRITE_EN_IN = '1' then
                data_in := RECORDED;
                sum <= alu_arithmetic(sum, RECORDED, "00");
               
               --If the count is less than 4 then increment the count by 1.
                if count < "00000000000000000000000000000100" then
                    temp_count := alu_arithmetic(temp_count, "00000000000000000000000000000001", "00"); --opcode for addition is 00
                end if;
                
                --If there are no items in the buffer then both the best and worst values are what was just recorded.
                if count = "00000000000000000000000000000000" then
                    best <= RECORDED;
                    worst <= RECORDED;
                else -- Otherwise check the incoming value with the stored best and worst values and update these values accordingly.
                    if RECORDED < best then
                        best <= RECORDED;
                    end if;
                    if RECORDED > worst then
                        worst <= RECORDED;
                    end if;
                end if;
                
                data_out := circ_buffer(write_pointer); --Value that is about to be overwitten
                --If there are three values in the buffer (so the buffer is full) then new best and worst values need to be calculated,
                --since the current best and worst values may be overwritten.
                if temp_count = "00000000000000000000000000000011" then
                    sum <= alu_arithmetic(sum, data_out, "01");
                    
                    if data_out = best then
                        best <= calculate_new_min_value(circ_buffer, zero, data_out, data_in);
                    end if;
                    if data_out = worst then
                        worst <= calculate_new_max_value(circ_buffer, data_out, data_in);
                    end if;
                end if;
                
                --If the write pointer is at the end of the buffer then wrap around to the start.
                if write_pointer = 2 then
                    write_pointer <= 0;
                else
                    write_pointer <= (write_pointer + 1) mod 3; -- Otherwise increment the write pointer
                end if;
                
                count <= temp_count; --Set the temp_count variable to the count signal
                circ_buffer(write_pointer) <= data_in; --Write the RECORDED value into the circular buffer.
                
            end if;
        end if;
end process;
-- Independent calculation for the average.
-- If the count is greater than zero then calculate a new average by dividing the sum of all the readings with the count.
-- Otherwise set the average to zero.
process(clk)
begin
    if reset = '0' then
        if count > zero then 
            average <= alu_arithmetic(sum, count, "11");
        else
            average <= zero;
        end if;
    else
        average <= zero;
    end if;
end process;

-- Add 1 to the best and worst values to match them with the recorded values.
process(best, worst)
    begin
    if best /= zero and worst /= zero and reset = '0' then
        actual_best <= alu_arithmetic(best, "00000000000000000000000000000001", "00");
        actual_worst <= alu_arithmetic(worst, "00000000000000000000000000000001", "00");
    elsif reset = '1' then
        actual_best <= zero;
        actual_worst <= zero;
    else
        actual_best <= best;
        actual_worst <= worst;
    end if;
end process;

--Update the best, worst, and average time messages to the FSM whenever the clock is triggered.
process (clk)
    begin
    if rising_edge(clk) then
        BEST_TIME <= actual_best;
        WORST_TIME <= actual_worst;
        AVERAGE_TIME <= average;
    end if;
end process;     

end Behavioural;        
          