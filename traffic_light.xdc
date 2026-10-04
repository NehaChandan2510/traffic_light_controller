## traffic_light.xdc
## Example constraints for a Digilent Basys3 (Artix-7, 100 MHz clock, sw/led I/O).
## Adjust pin locations to match your own board's master.xdc / schematic.
## If you're only simulating (no board yet), you don't need this file at all.

## 100 MHz system clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## Reset button (BTNC)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## Road A - Green/Yellow/Red on LEDs 0-2
set_property PACKAGE_PIN U16 [get_ports {lightA[2]}]
set_property PACKAGE_PIN E19 [get_ports {lightA[1]}]
set_property PACKAGE_PIN U19 [get_ports {lightA[0]}]

## Road B - LEDs 3-5
set_property PACKAGE_PIN V19 [get_ports {lightB[2]}]
set_property PACKAGE_PIN W18 [get_ports {lightB[1]}]
set_property PACKAGE_PIN U15 [get_ports {lightB[0]}]

## Road C - LEDs 6-8
set_property PACKAGE_PIN U14 [get_ports {lightC[2]}]
set_property PACKAGE_PIN V14 [get_ports {lightC[1]}]
set_property PACKAGE_PIN V13 [get_ports {lightC[0]}]

## Road D - LEDs 9-11
set_property PACKAGE_PIN V3  [get_ports {lightD[2]}]
set_property PACKAGE_PIN W3  [get_ports {lightD[1]}]
set_property PACKAGE_PIN U3  [get_ports {lightD[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {lightA[*] lightB[*] lightC[*] lightD[*]}]
