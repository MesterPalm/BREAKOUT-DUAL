vcom ../breakout.vhd ../uMem.vhd ../pMem.vhd
vsim breakout_tb

add wave {sim:/breakout_tb/uut/clk }
add wave {sim:/breakout_tb/uut/rst }
add wave -bin {sim:/breakout_tb/uut/JA }
add wave -bin {sim:/breakout_tb/uut/JB }
add wave -bin {sim:/breakout_tb/uut/Led }
add wave -dec {sim:/breakout_tb/uut/ul/q }
add wave -dec {sim:/breakout_tb/uut/ul/us }
add wave -dec {sim:/breakout_tb/uut/ul/us_counter }
add wave -dec {sim:/breakout_tb/uut/ul/us_time }
add wave -dec {sim:/breakout_tb/uut/ul/us_rst }
add wave -bin {sim:/breakout_tb/uut/ul/trigger }
add wave -bin {sim:/breakout_tb/uut/ul/echo }

# add wave -dec {sim:/breakout_tb/uut/upc }
# add wave -hex {sim:/breakout_tb/uut/tb }
# add wave -hex {sim:/breakout_tb/uut/fb }
# add wave -dec {sim:/breakout_tb/uut/pc }
# add wave -hex {sim:/breakout_tb/uut/ir }

# add wave -hex {sim:/breakout_tb/uut/u0/uaddr }
# add wave -hex {sim:/breakout_tb/uut/u1/paddr }
# add wave -hex {sim:/breakout_tb/uut/u1/pdata }

restart -f
run 200 us
