library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_Receiver is
  generic (
    -- ClkCyclesPerBit : integer := 115
      ClkCyclesPerBit : integer := 300000000
    );
  port (
    Clock       : in  std_logic;
    -- SerialInput : in  std_logic;
    DataValid   : out std_logic;
    Test        : out std_logic;

    Test2      : out std_logic;
    Test3      : out std_logic;

    anode      : out std_logic_vector(7 downto 0);
    seg       : out std_logic_vector(6 downto 0);
    -- ReceivedByte: out std_logic_vector(7 downto 0)

    --Transmitter Variables
    TransmitByte_SW : in std_logic_vector(7 downto 0);
    TransmitActive_Light  : out std_logic;
    Transmit_Button : in std_logic;

    TransmitPort : out std_logic;
    ReceivePort : in std_logic
    );
end UART_Receiver;

architecture rtl of UART_Receiver is

	COMPONENT leddec IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- DON'T change, data is fixed 4 bits in leddec for each displays
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;

  COMPONENT UART_Transmitter IS
    GENERIC (
      ClkCyclesPerBit : integer := 300000000
    );
    PORT (
      Clock        : in  std_logic;
      TransmitDV   : in  std_logic;                 -- Data Valid signal for transmission
      TransmitByte : in  std_logic_vector(7 downto 0); -- Byte to transmit
      TX_Active    : out std_logic;                 -- Indicates transmission is active
      TX_Serial    : out std_logic                 -- Serial output
      -- TX_Done      : out std_logic                  -- Transmission done signal
    );
  END COMPONENT;

  type StateMachine is (Idle, ReceivingStartBit, ReceivingDataBits,
                        ReceivingStopBit, Cleanup);
  signal CurrentState : StateMachine := Idle;

  signal SerialDataReg : std_logic := '0';
  signal SerialData    : std_logic := '0';
   
  signal ClockCounter  : integer range 0 to ClkCyclesPerBit-1 := 0;
  signal BitCounter    : integer range 0 to 7 := 0;
  signal ByteAssembly  : std_logic_vector(7 downto 0) := (others => '0');
  signal DataReady     : std_logic := '0';

  signal cnt : STD_LOGIC_VECTOR(32 downto 0) := (others => '0');
  signal dig : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');

  signal SerialInput   : std_logic := '1';



   
begin
  -- Recieve Port test
  Test <= ReceivePort;
  SerialInput <= ReceivePort;



  -- Instantiate the UART Transmitter
  UART_Transmitter_Inst : UART_Transmitter
  GENERIC MAP (
    ClkCyclesPerBit => ClkCyclesPerBit
  )
  PORT MAP (
    Clock        => Clock,
    TransmitDV   => Transmit_Button,
    TransmitByte => TransmitByte_SW,
    TX_Active    => TransmitActive_Light,  
    TX_Serial    => TransmitPort
    -- TX_Done      => TX_Done
  );



  dig <= cnt(19 downto 17);
  L1 : leddec 
  PORT MAP (
    dig => dig,
    data => ByteAssembly,
    anode => anode,
    seg => seg
  );

  SerialInputSampling : process (Clock)
  begin

    if rising_edge(Clock) then
      cnt <= cnt + 1;

      -- Shift the SerialInput into the SerialDataReg
      SerialDataReg <= SerialInput;
      SerialData    <= SerialDataReg; 

    end if; 
  end process SerialInputSampling;

  UARTReceivingProcess : process (Clock)
  begin
    if rising_edge(Clock) then
      case CurrentState is
        when Idle =>
          DataReady   <= '0';
          ClockCounter <= 0;
          BitCounter  <= 0;
          if SerialData = '0' then
            CurrentState <= ReceivingStartBit;
          else
            CurrentState <= Idle;
          end if;

        when ReceivingStartBit =>
          if ClockCounter >= (ClkCyclesPerBit-1)/2 then
            if SerialData = '0' then
              ClockCounter <= 0;
              CurrentState <= ReceivingDataBits;
            else
              CurrentState <= Idle;
            end if;
          else
            ClockCounter <= ClockCounter + 1;
            CurrentState <= ReceivingStartBit;
          end if;

        when ReceivingDataBits =>
          if ClockCounter < ClkCyclesPerBit-1 then
            ClockCounter <= ClockCounter + 1;
            CurrentState <= ReceivingDataBits;
          else
            ClockCounter         <= 0;
            ByteAssembly(BitCounter) <= SerialData;
            if BitCounter < 7 then
              BitCounter  <= BitCounter + 1;
              CurrentState <= ReceivingDataBits;
            else
              BitCounter  <= 0;
              CurrentState <= ReceivingStopBit;
            end if;
          end if;

        when ReceivingStopBit =>
          if ClockCounter < ClkCyclesPerBit-1 then
            ClockCounter <= ClockCounter + 1;
            CurrentState <= ReceivingStopBit;
          else
            DataReady    <= '1';
            ClockCounter <= 0;
            CurrentState <= Cleanup;
          end if;

        when Cleanup =>
          CurrentState <= Idle;
          DataReady    <= '0';

        when others =>
          CurrentState <= Idle;
      end case;
    end if;
  end process UARTReceivingProcess;

  DataValid    <= DataReady;
  -- ReceivedByte <= ByteAssembly;

  -- If Clock Counter > 10 then set Test2 to 1
  Test2 <= '1' when ClockCounter > 150000000 else '0';


end rtl;
