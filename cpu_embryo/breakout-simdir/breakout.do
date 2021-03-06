vcom ../breakout.vhd ../uMem.vhd ../pMem.vhd
vsim breakout_tb

add wave {sim:/breakout_tb/uut/clk }
add wave {sim:/breakout_tb/uut/rst }

add wave -dec {sim:/breakout_tb/uut/upc }
add wave -hex {sim:/breakout_tb/uut/tb }
add wave -hex {sim:/breakout_tb/uut/fb }
add wave -dec {sim:/breakout_tb/uut/pc }
add wave -hex {sim:/breakout_tb/uut/ir }

add wave -hex {sim:/breakout_tb/uut/u0/uaddr }
add wave -hex {sim:/breakout_tb/uut/u1/paddr }
add wave -hex {sim:/breakout_tb/uut/u1/pdata }

restart -f
run 200 us
