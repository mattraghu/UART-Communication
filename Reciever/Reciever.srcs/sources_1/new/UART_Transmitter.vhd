library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- UART Transmitter Entity Declaration
entity UART_Transmitter is
  generic (
    ClkCyclesPerBit : integer := 100000000
    );
  port (
    Clock        : in  std_logic;
    TransmitDV   : in  std_logic;                 -- Data Valid signal for transmission
    TransmitByte : in  std_logic_vector(7 downto 0); -- Byte to transmit
    TX_Active    : out std_logic;                 -- Indicates transmission is active
    TX_Serial    : out std_logic                 -- Serial output
    -- TX_Done      : out std_logic                  -- Transmission done signal
    );
end UART_Transmitter;

-- Architecture of UART Transmitter
architecture RTL of UART_Transmitter is

  type StateMachine is (Idle, TX_StartBit, TX_DataBits,
                        TX_StopBit, Cleanup);
  signal CurrentState : StateMachine := Idle;

  signal ClockCounter : integer range 0 to ClkCyclesPerBit-1 := 0;
  signal BitIndex     : integer range 0 to 7 := 0;  -- For 8-bit data
  signal TX_Data      : std_logic_vector(7 downto 0) := (others => '0');
  signal TX_Complete  : std_logic := '0';

--   signal TransmitByte : std_logic_vector(7 downto 0) := "00000111";
   
begin

  -- UART Transmitter Process
  UART_TX_Process : process (Clock)
  begin
    if rising_edge(Clock) then
      case CurrentState is

        -- Idle State: Wait for data valid signal
        when Idle =>
          TX_Active <= '0';
          TX_Serial <= '1';         -- Line High for Idle
          TX_Complete <= '0';
          ClockCounter <= 0;
          BitIndex <= 0;

          if TransmitDV = '1' then
            TX_Data <= TransmitByte;
            CurrentState <= TX_StartBit;
          else
            CurrentState <= Idle;
          end if;

        -- Transmitting Start Bit (logic '0')
        when TX_StartBit =>
          TX_Active <= '1';
          TX_Serial <= '0';

          -- Timing for Start Bit
          if ClockCounter < ClkCyclesPerBit-1 then
            ClockCounter <= ClockCounter + 1;
            CurrentState <= TX_StartBit;
          else
            ClockCounter <= 0;
            CurrentState <= TX_DataBits;
          end if;

        -- Transmitting Data Bits
        when TX_DataBits =>
          TX_Serial <= TX_Data(BitIndex);
           
          -- Timing for each Data Bit
          if ClockCounter < ClkCyclesPerBit-1 then
            ClockCounter <= ClockCounter + 1;
            CurrentState <= TX_DataBits;
          else
            ClockCounter <= 0;
            if BitIndex < 7 then
              BitIndex <= BitIndex + 1;
              CurrentState <= TX_DataBits;
            else
              BitIndex <= 0;
              CurrentState <= TX_StopBit;
            end if;
          end if;

        -- Transmitting Stop Bit (logic '1')
        when TX_StopBit =>
          TX_Serial <= '1';

          -- Timing for Stop Bit
          if ClockCounter < ClkCyclesPerBit-1 then
            ClockCounter <= ClockCounter + 1;
            CurrentState <= TX_StopBit;
          else
            TX_Complete <= '1';
            ClockCounter <= 0;
            CurrentState <= Cleanup;
          end if;

        -- Cleanup State: Prepare for next transmission
        when Cleanup =>
          TX_Active <= '0';
          TX_Complete <= '1';
          CurrentState <= Idle;

        -- Default case
        when others =>
          CurrentState <= Idle;

      end case;
    end if;
  end process UART_TX_Process;

  -- Output signal for transmission completion
  -- TX_Done <= TX_Complete;

end RTL;
