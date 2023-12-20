LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- which digit to currently display
		data : IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- 16-bit (4-digit) data
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- segment code for current digit
END leddec;

ARCHITECTURE Behavioral OF leddec IS
	SIGNAL data4 : STD_LOGIC_VECTOR (4 DOWNTO 0); -- binary value of current digit
BEGIN
	-- Select digit data to be displayed in this mpx period
	data4(4 DOWNTO 1) <= data(3 DOWNTO 0) WHEN dig = "000" ELSE -- digit 0
	         data(7 DOWNTO 4) WHEN dig = "001" ELSE -- digit 1
			 "0000";
	        --  data(11 DOWNTO 8) WHEN dig = "010" ELSE -- digit 2
	        --  data(15 DOWNTO 12); -- digit 3

	--Remove trailing zeros
	data4(0) <=
			-- '1' WHEN data(7 DOWNTO 4) = "0000" AND dig = "001";-- If the last digit is 0, turn off the last digit
			'0' WHEN (dig = "001" or dig = "000") ELSE
			'1';

	-- data4(0) <= 
	-- 		'1' WHEN data(15 DOWNTO 12) = "0000" AND dig = "011" ELSE -- If the last digit is 0, turn off the last digit
	-- 		'1' WHEN data(15 DOWNTO 8) = "00000000" AND dig = "010" ELSE -- If the last two digits are 0, turn off the last two digits
	-- 		'1' WHEN data(15 DOWNTO 4) = "000000000000" AND dig = "001" ELSE -- If the last three digits are 0, turn off the last three digits
	-- 		'0';	-- Otherwise, turn on the last digit
	data4(0) <= '0';



	-- Turn on segments corresponding to 4-bit data word
	seg <= "0000001" WHEN data4 = "00000" ELSE -- 0
	       "1001111" WHEN data4 = "00010" ELSE -- 1
	       "0010010" WHEN data4 = "00100" ELSE -- 2
	       "0000110" WHEN data4 = "00110" ELSE -- 3
	       "1001100" WHEN data4 = "01000" ELSE -- 4
	       "0100100" WHEN data4 = "01010" ELSE -- 5
	       "0100000" WHEN data4 = "01100" ELSE -- 6
	       "0001111" WHEN data4 = "01110" ELSE -- 7
	       "0000000" WHEN data4 = "10000" ELSE -- 8
	       "0000100" WHEN data4 = "10010" ELSE -- 9
	       "0001000" WHEN data4 = "10100" ELSE -- A
	       "1100000" WHEN data4 = "10110" ELSE -- B
	       "0110001" WHEN data4 = "11000" ELSE -- C
	       "1000010" WHEN data4 = "11010" ELSE -- D
	       "0110000" WHEN data4 = "11100" ELSE -- E
	       "0111000" WHEN data4 = "11110" ELSE -- F
	       "1111111";
	-- Turn on anode of 7-segment display addressed by 3-bit digit selector dig
	anode <= "11111110" WHEN dig = "000" ELSE -- 0
	         "11111101" WHEN dig = "001" ELSE -- 1
	         "11111011" WHEN dig = "010" ELSE -- 2
	         "11110111" WHEN dig = "011" ELSE -- 3
--	         "11101111" WHEN dig = "100" ELSE -- 4
--	         "11011111" WHEN dig = "101" ELSE -- 5 
--	         "10111111" WHEN dig = "110" ELSE -- 6
--	         "01111111" WHEN dig = "111" ELSE -- 7
	         "11111111";
END Behavioral;