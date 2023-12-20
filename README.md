# UART - Communication

## Description

The goal of this project is to create a communication between two Nexys 100T boards using the UART protocol. A transmitter sends an eight bit number based on a switch input to a receiver. The receiver then displays the number on the seven segment display.

## How it works?

The whole program relies on the board's built in 100MHz clock. Each bit is sent in intervals. Let's first look at the `UART_Transmitter.vhd` script and analyze it.

### Transmitter

```vhdl
ClkCyclesPerBit : integer := 100000000
```

In this case, because we're using a 100MHz clock, we can calculate how long each bit will be sent.

$$
\frac{100000000 \text{ cycles}}{1 \text{ bit}} \cdot \frac{1 \text{s}}{100000000 \text{ cycles}} = 1 \text{s per bit}
$$

So with the 100000000 cycles per bit, each bit will be sent for 1 second.

#### Important Signals/Ports

##### TransmitDV

```vhdl
TransmitDV   : in  std_logic;                 -- Data Valid signal for transmission
```

This is attached to a button on the board that will trigger the transmission of the data.

##### TransmitByte

```vhdl
TransmitByte : in  std_logic_vector(7 downto 0); -- Data to be transmitted
```

This is attached to the switches on the board. This is the number that will be transmitted.

##### TX_Active

```vhdl
TX_Active    : out std_logic;                 -- Transmitter Active signal
```

This is attached to an LED on the board. This will light up when the transmitter is active.

##### TX_Serial

```vhdl
TX_Serial    : out std_logic;                 -- Serial output
```

This is the current bit that is being sent. It is attached to the output pin on the board.

#### Stages

The transmission cycle is split up into 5 parts:

```vhdl
type StateMachine is (Idle, TX_StartBit, TX_DataBits,
                    TX_StopBit, Cleanup);
signal CurrentState : StateMachine := Idle;
```

##### Idle

```vhdl
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
```

In this state, the transmitter is idle. It will wait for the `TransmitDV` signal to be high. Once it is high, it will move to the `TX_StartBit` state.

##### TX_StartBit

```vhdl
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
```

In this state, the transmitter will switch from sending a high signal to a low signal. This is the start bit. It will then move to the `TX_DataBits` state.

##### TX_DataBits

```vhdl
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
```

In this state, the transmitter will send the data bits. It will send the bits in order from the least significant bit to the most significant bit. Once it has sent all the bits, it will move to the `TX_StopBit` state.

##### TX_StopBit

```vhdl
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
```

In this state, the transmitter will send a high signal. This is the stop bit. Once it has sent the stop bit, it will move to the `Cleanup` state.

##### Cleanup

```vhdl
TX_Active <= '0';
TX_Complete <= '1';
CurrentState <= Idle;
```

In this state, the transmitter will set the `TX_Active` and `TX_Complete` signals to high. It will then move back to the `Idle` state.

### Receiver

The reciever is a little more complicated than the transmitter. It has to be able to read the data that is being sent and display it on the seven segment display.

#### Important Signals/Ports

##### SerialData

```vhdl
signal SerialData    : std_logic := '0';
```

This is the current bit that is being recieved. It is attached to the input pin on the board.

##### ByteAssembly

```vhdl
signal ByteAssembly  : std_logic_vector(7 downto 0) := (others => '0');
```

This is the current byte that is being assembled. It is initialized to all zeros. As the bits are recieved, the respective bit in the byte will be changed.

##### DataReady

```vhdl
signal DataReady     : std_logic := '0';
```

This indicated whether or not the data is finished being recieved. It is attached to an LED on the board.

#### Stages

##### Idle

```vhdl
DataReady   <= '0';
ClockCounter <= 0;
BitCounter  <= 0;
if SerialData = '0' then
    CurrentState <= ReceivingStartBit;
else
    CurrentState <= Idle;
end if;
```

In this state, the receiver is idle. It will wait for the `SerialData` signal to be low. Once it is low, it will move to the `ReceivingStartBit` state.

##### ReceivingStartBit

```vhdl
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
```

In this state, the receiver will wait for the `SerialData` signal to be high. Once it is high, it will move to the `ReceivingDataBits` state.

##### ReceivingDataBits

```vhdl
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
```

In this state, the receiver will read the data bits. It will read the bits in order from the least significant bit to the most significant bit. Once it has read all the bits, it will move to the `ReceivingStopBit` state.

##### ReceivingStopBit

```vhdl
if ClockCounter < ClkCyclesPerBit-1 then
    ClockCounter <= ClockCounter + 1;
    CurrentState <= ReceivingStopBit;
else
    DataReady    <= '1';
    ClockCounter <= 0;
    CurrentState <= Cleanup;
end if;
```

In this state, the receiver will wait for the `SerialData` signal to be high. Once it is high, it will move to the `Cleanup` state.

##### Cleanup

```vhdl
CurrentState <= Idle;
DataReady    <= '0';
```

In this state, the receiver will set the `DataReady` signal to high. It will then move back to the `Idle` state.

#### Displaying the Data

The reciever script is also where we implement the seven segment display. From past labs we know how the leddec module works. It just needs to be adjusted to use 8 bits.

```vhdl
data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
```

It's connected to the following ports:

```vhdl
L1 : leddec
PORT MAP (
    dig => dig,
    data => ByteAssembly,
    anode => anode,
    seg => seg
);
```

For this to work we had to create a new cnt variable that would increment every clock cycle. Dig (the screen that is being displayed) is set to 19th-17th bits of the cnt variable. This allows the display to cycle.

The data is set to the `ByteAssembly` signal, which if you remember is the byte that is being assembled from the bits that are being recieved.
