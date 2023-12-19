library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity UART_Receiver is
  generic (
    ClkCyclesPerBit : integer := 115
    );
  port (
    Clock       : in  std_logic;
    SerialInput : in  std_logic;
    DataValid   : out std_logic;
    ReceivedByte: out std_logic_vector(7 downto 0)
    );
end UART_Receiver;

architecture rtl of UART_Receiver is

  type StateMachine is (Idle, ReceivingStartBit, ReceivingDataBits,
                        ReceivingStopBit, Cleanup);
  signal CurrentState : StateMachine := Idle;

  signal SerialDataReg : std_logic := '0';
  signal SerialData    : std_logic := '0';
   
  signal ClockCounter  : integer range 0 to ClkCyclesPerBit-1 := 0;
  signal BitCounter    : integer range 0 to 7 := 0;
  signal ByteAssembly  : std_logic_vector(7 downto 0) := (others => '0');
  signal DataReady     : std_logic := '0';
   
begin

  SerialInputSampling : process (Clock)
  begin
    if rising_edge(Clock) then
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
          if ClockCounter = (ClkCyclesPerBit-1)/2 then
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
  ReceivedByte <= ByteAssembly;

end rtl;
