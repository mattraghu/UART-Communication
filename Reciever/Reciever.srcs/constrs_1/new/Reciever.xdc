#FPGA I/0 Locations

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports Clock]

set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {seg[6]}]

set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {anode[7]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {anode[6]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {anode[5]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {anode[4]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {anode[3]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {anode[2]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {anode[1]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {anode[0]}]

set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { SerialInput }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {DataValid}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {Test}]

set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {Test2}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {Test3}]

# # Switches for changing the transmit byte
# set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {TransmitByte_SW[0]}]
# set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {TransmitByte_SW[1]}]
# set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {TransmitByte_SW[2]}]
# set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {TransmitByte_SW[3]}]
# set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {TransmitByte_SW[4]}]
# set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {TransmitByte_SW[5]}]
# set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {TransmitByte_SW[6]}]
# set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {TransmitByte_SW[7]}]