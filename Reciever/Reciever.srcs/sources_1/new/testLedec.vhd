-- testLedec.vhd --

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY testLedec IS
	PORT (
		clk_100MHz : IN STD_LOGIC;
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END testLedec;

ARCHITECTURE Behavioral OF testLedec IS

	COMPONENT leddec IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- DON'T change, data is fixed 4 bits in leddec for each displays
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;

    SIGNAL S : STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000110111"; -- Connect C1 and L1 for values of 4 digits (Default to 7)
	SIGNAL md : STD_LOGIC_VECTOR (2 DOWNTO 0); -- mpx selects displays
	SIGNAL display : STD_LOGIC_VECTOR (3 DOWNTO 0); -- Send digit for only one display to leddec
    SIGNAL counter : STD_LOGIC_VECTOR (26 DOWNTO 0); --:= "000000000000000000000000000"; -- (2**27/(100E6)) = 1.34217728s for one cycle

BEGIN
	L1 : leddec
	PORT MAP(dig => md, data => S, anode => anode, seg => seg);

    -- Counter Process 
    PROCESS(clk_100MHz)
    BEGIN
        IF (rising_edge(clk_100MHz)) THEN
            -- IF (counter = "111111111111111111111111111") THEN
            --     counter <= "000000000000000000000000000";
            -- ELSE
                counter <= counter + 1;
            -- END IF;
        END IF;
    END PROCESS;

    -- Process To Change Dig Every 1s
    md <= counter(19 DOWNTO 17);
    -- PROCESS(counter)
    -- BEGIN
    --     IF (counter = "111111111111111111111111111") THEN
    --         -- IF (md = "111") THEN
    --         --     md <= "000";
    --         -- ELSE
    --             md <= md + 1;
    --         -- END IF;
    --     END IF;
    -- END PROCESS;

    

	--mpx
	--process(md)
	--begin
	-- if md = "00" then
	-- display <= S(3 downto 0);
	-- elsif md = "01" then
	-- display <= S(7 downto 4);
	-- elsif md = "10" then
	-- display <= S(11 downto 8);
	-- elsif md = "11" then
	-- display <= S(15 downto 12);
	-- end if;
	--end process;

	display <= S(3 DOWNTO 0) WHEN md = "000" ELSE
	           S(7 DOWNTO 4) WHEN md = "001" ELSE
	           S(11 DOWNTO 8) WHEN md = "010" ELSE
	           S(15 DOWNTO 12);

END Behavioral;