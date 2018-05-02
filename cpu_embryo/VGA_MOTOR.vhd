--------------------------------------------------------------------------------
-- VGA MOTOR
-- Anders Nilsson
-- 16-feb-2016
-- Version 1.1


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity VGA_MOTOR is
  port ( clk			: in std_logic;
	 data			: in std_logic_vector(7 downto 0);
	 addr			: out unsigned(10 downto 0);
	 rst			: in std_logic;
	 vgaRed		        : out std_logic_vector(2 downto 0);
	 vgaGreen	        : out std_logic_vector(2 downto 0);
	 vgaBlue		: out std_logic_vector(2 downto 1);
	 Hsync		        : out std_logic;
	 Vsync		        : out std_logic;
         -- first bit 1 if collision, 3-bit enumerated normal.
         collision_one          : buffer unsigned(3 downto 0);
         collision_two          : buffer unsigned(3 downto 0);
         -- The balls start_stop X and start_stop Y.
         ball_one_posX          : in unsigned(9 downto 0);
         ball_one_posY          : in unsigned(9 downto 0);
         ball_two_posX          : in unsigned(9 downto 0);
         ball_two_posY          : in unsigned(9 downto 0);
         collision_reset        : in std_logic
         
         );
end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

  signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal
		
  signal 	outPixel        : unsigned(7 downto 0);	-- output pixel data
  signal	tileAddr	: unsigned(10 downto 0);	-- Tile address

  signal        blank           : std_logic;                    -- blanking signal

  signal  ball_one_posX_end      : unsigned(9 downto 0);
  signal  ball_one_posY_end      : unsigned(9 downto 0);
  signal  ball_two_posX_end      : unsigned(9 downto 0);
  signal  ball_two_posY_end      : unsigned(9 downto 0);

  signal addr_one : unsigned(5 downto 0);
  signal addr_two : unsigned(5 downto 0);

  signal inside_one : std_logic;
  signal inside_two : std_logic;
  signal transparent_one : std_logic;
  signal transparent_two : std_logic;
  signal sub_oneY : unsigned(9 downto 0);
  signal sub_oneX : unsigned(9 downto 0);
  signal sub_twoY : unsigned(9 downto 0);
  signal sub_twoX : unsigned(9 downto 0);
  
  signal temp : std_logic;
	

  -- Tile memory type
  type ram_t is array (0 to 2047) of unsigned(11 downto 0);

-- Tile memory
-- colour chart http://www.fountainware.com/EXPL/vga_color_palettes.htm
  signal tileMem : ram_t := 
		( 
                  -- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"0FF",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"0FF",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"0FF",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"0FF",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"0FF",x"000",x"000",x"000",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"000",x"000",x"000",x"000",x"000",x"0FF",x"000", 
x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"B25",x"A25",x"A25",x"A25",x"A25",x"A25",x"A25",x"925", 
x"C25",x"025",x"025",x"025",x"025",x"025",x"025",x"825", 
x"C25",x"025",x"025",x"025",x"025",x"025",x"025",x"825", 
x"C25",x"025",x"025",x"025",x"025",x"025",x"025",x"825", 
x"C25",x"025",x"025",x"025",x"025",x"025",x"025",x"825", 
x"C25",x"025",x"025",x"025",x"025",x"025",x"025",x"825", 
x"C25",x"025",x"025",x"025",x"025",x"025",x"025",x"825", 
x"D25",x"E25",x"E25",x"E25",x"E25",x"E25",x"E25",x"F25", 



-- Tile start

x"B27",x"A27",x"A27",x"A27",x"A27",x"A27",x"A27",x"F27", 
x"C27",x"027",x"027",x"027",x"027",x"027",x"F27",x"000", 
x"C27",x"027",x"027",x"027",x"027",x"F27",x"000",x"000", 
x"C27",x"027",x"027",x"027",x"F27",x"000",x"000",x"000", 
x"C27",x"027",x"027",x"F27",x"000",x"000",x"000",x"000", 
x"C27",x"027",x"F27",x"000",x"000",x"000",x"000",x"000", 
x"C27",x"F27",x"000",x"000",x"000",x"000",x"000",x"000", 
x"F27",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"D27",x"A27",x"A27",x"A27",x"A27",x"A27",x"A27",x"927", 
x"000",x"D27",x"027",x"027",x"027",x"027",x"027",x"827", 
x"000",x"000",x"D27",x"027",x"027",x"027",x"027",x"827", 
x"000",x"000",x"000",x"D27",x"027",x"027",x"027",x"827", 
x"000",x"000",x"000",x"000",x"D27",x"027",x"027",x"827", 
x"000",x"000",x"000",x"000",x"000",x"D27",x"027",x"827", 
x"000",x"000",x"000",x"000",x"000",x"000",x"D27",x"827", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"D27", 



-- Tile start

x"927",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"C27",x"927",x"000",x"000",x"000",x"000",x"000",x"000", 
x"C27",x"027",x"927",x"000",x"000",x"000",x"000",x"000", 
x"C27",x"027",x"027",x"927",x"000",x"000",x"000",x"000", 
x"C27",x"027",x"027",x"027",x"927",x"000",x"000",x"000", 
x"C27",x"027",x"027",x"027",x"027",x"927",x"000",x"000", 
x"C27",x"027",x"027",x"027",x"027",x"027",x"927",x"000", 
x"D27",x"E27",x"E27",x"E27",x"E27",x"E27",x"E27",x"927", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"B27", 
x"000",x"000",x"000",x"000",x"000",x"000",x"B27",x"827", 
x"000",x"000",x"000",x"000",x"000",x"B27",x"027",x"827", 
x"000",x"000",x"000",x"000",x"B27",x"027",x"027",x"827", 
x"000",x"000",x"000",x"B27",x"027",x"027",x"027",x"827", 
x"000",x"000",x"B27",x"027",x"027",x"027",x"027",x"827", 
x"000",x"B27",x"027",x"027",x"027",x"027",x"027",x"827", 
x"B27",x"E27",x"E27",x"E27",x"E27",x"E27",x"E27",x"F27", 



-- Tile start

x"B4A",x"A4A",x"A4A",x"A4A",x"A4A",x"A4A",x"A4A",x"94A", 
x"C4A",x"04A",x"04A",x"04A",x"04A",x"04A",x"04A",x"84A", 
x"C4A",x"04A",x"04A",x"04A",x"04A",x"04A",x"04A",x"84A", 
x"C4A",x"04A",x"04A",x"04A",x"04A",x"04A",x"04A",x"84A", 
x"C4A",x"04A",x"04A",x"04A",x"04A",x"04A",x"04A",x"84A", 
x"C4A",x"04A",x"04A",x"04A",x"04A",x"04A",x"04A",x"84A", 
x"C4A",x"04A",x"04A",x"04A",x"04A",x"04A",x"04A",x"84A", 
x"D4A",x"E4A",x"E4A",x"E4A",x"E4A",x"E4A",x"E4A",x"F4A", 



-- Tile start

x"B0C",x"A0C",x"A0C",x"A0C",x"A0C",x"A0C",x"A0C",x"90C", 
x"C0C",x"00C",x"00C",x"00C",x"00C",x"00C",x"00C",x"80C", 
x"C0C",x"00C",x"00C",x"00C",x"00C",x"00C",x"00C",x"80C", 
x"C0C",x"00C",x"00C",x"00C",x"00C",x"00C",x"00C",x"80C", 
x"C0C",x"00C",x"00C",x"00C",x"00C",x"00C",x"00C",x"80C", 
x"C0C",x"00C",x"00C",x"00C",x"00C",x"00C",x"00C",x"80C", 
x"C0C",x"00C",x"00C",x"00C",x"00C",x"00C",x"00C",x"80C", 
x"D0C",x"E0C",x"E0C",x"E0C",x"E0C",x"E0C",x"E0C",x"F0C", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 



-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",

-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000",

-- Tile start

x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000", 
x"000",x"000",x"000",x"000",x"000",x"000",x"000",x"000"
                  
                  );
  
  -- Ball memory type
  type balls is array (0 to 63) of unsigned(11 downto 0);

  signal ballSprite : balls := 
		( 

x"000",x"B00",x"AFF",x"AFF",x"AFF",x"AFF",x"900",x"000", 
x"B00",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"900", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"D00",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"F00", 
x"000",x"D00",x"EFF",x"EFF",x"EFF",x"EFF",x"F00",x"000"

                  );
  
  -- Paddle memory type
  type paddles is array (0 to 767) of unsigned(11 downto 0);

  signal paddleSprite : paddles := 
		( 
                  x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF",x"BFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"AFF",x"9FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF",x"CFF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"8FF", 
x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF",x"DFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"EFF",x"FFF"
                  );
		  
begin

  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	ClkDiv <= (others => '0');
      else
	ClkDiv <= ClkDiv + 1;
      end if;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	
  -- Horizontal pixel counter

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Xpixel                         *
  -- *                                 *
  -- ***********************************
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        Xpixel <= B"0000000000";
      elsif Clk25='1' then
        if Xpixel=799 then
          Xpixel <= B"0000000000";
        else
          Xpixel <= Xpixel + 1;    
        end if;                        
      end if;
    end if;
  end process;
      

  
  -- Horizontal sync

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Hsync                          *
  -- *                                 *
  -- ***********************************
  Hsync <= '0' when (Xpixel >= 656 and Xpixel < 752) else '1';

  
  -- Vertical pixel counter

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Ypixel                         *
  -- *                                 *
  -- ***********************************
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        Ypixel <= B"0000000000";
      elsif Clk25='1' then
        if Ypixel=520 then
          Ypixel <= B"0000000000";
        elsif Xpixel=799 then
          Ypixel <= Ypixel + 1;    
        end if;                        
      end if;
    end if;
  end process;
	

  -- Vertical sync

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Vsync                          *
  -- *                                 *
  -- ***********************************
  Vsync <= '0' when (Ypixel >= 490 and Ypixel < 492) else '1';


  
  -- Video blanking signal

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  Blank                          *
  -- *                                 *
  -- ***********************************
  blank <= '1' when (Xpixel >= 640 or Ypixel >= 480) else '0';


  
  -- Tile memory
  --process(clk)
  --begin
  --  if rising_edge(clk) then
  --    if (blank = '0') then
  --      outPixel <= tileMem(to_integer(tileAddr))(7 downto 0);
  --   else
  --      outPixel <= (others => '0');
  --    end if;
  --  end if;
  --end process;


  -- Collision logic
  --collision <= '1' when (
	


  -- Tile memory address composite
  tileAddr <= unsigned(data(4 downto 0)) & Ypixel(4 downto 2) & Xpixel(4 downto 2);


  -- Picture memory address composite
  addr <= to_unsigned(20, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5);


  -- VGA generation
  vgaRed(2) 	<= outPixel(7);
  vgaRed(1) 	<= outPixel(6);
  vgaRed(0) 	<= outPixel(5);
  vgaGreen(2)   <= outPixel(4);
  vgaGreen(1)   <= outPixel(3);
  vgaGreen(0)   <= outPixel(2);
  vgaBlue(2) 	<= outPixel(1);
  vgaBlue(1) 	<= outPixel(0);
  
  -----------------------------------------------------------------------------
  -- Start of K-nät for the muxing of tiles and sprites.
  -----------------------------------------------------------------------------
  -- Inside sprites
  -- one
  ball_one_posX_end <= ball_one_posX + 7;
  ball_one_posY_end <= ball_one_posY + 7;
  inside_one <= '1' when Xpixel >= ball_one_posX(9 downto 0) and Xpixel <= ball_one_posX_end(9 downto 0) and Ypixel >= ball_one_posX(9 downto 0) and Ypixel <= ball_one_posX_end(9 downto 0) else '0';
  -- two
  ball_two_posX_end <= ball_two_posY + 8;
  ball_two_posY_end <= ball_two_posY + 8;
  inside_two <= '1' when Xpixel >= ball_two_posX(9 downto 0) and Xpixel <= ball_two_posX_end(9 downto 0) and Ypixel >= ball_two_posX(9 downto 0) and Ypixel <= ball_two_posX_end(9 downto 0) else '0';

  --Sprite adress (6-bit)
  -- one
  sub_oneY <= Ypixel - ball_one_posY;
  sub_oneX <= Xpixel - ball_one_posX; 
  addr_one <= sub_oneY(2 downto 0) & sub_oneX(2 downto 0);
  -- two
  sub_twoY <= Ypixel - ball_two_posY;
  sub_twoX <= Xpixel - ball_two_posX;
  addr_two <= sub_twoY(2 downto 0) & sub_twoX(2 downto 0);
  
  -- Transparent
  transparent_one <= '1' when (inside_one = '1' and ballSprite(to_integer(addr_one)) = x"000") or inside_one = '0'  else '0';
  transparent_two <= '1' when (inside_two = '1' and ballSprite(to_integer(addr_two)) = x"000") or inside_one = '0' else '0';

  -- Kollision kanske ska lösas med process sats då vi inte vill skriva över en
  -- kollision. Collision behöver vara inout eller kollisionsflaggan behövs för
  -- att inte skriva över tidigare resultat.
  -- Collision
  -- one
  process(clk)
  begin
    if rising_edge(clk) then
      if collision_reset = '1' then
        collision_one(3) <= '0';
      elsif collision_one(3) = '0' and transparent_one = '0' and tileMem(to_integer(tileAddr))(11) = '1' then
        collision_one(3) <= '1';
        collision_one(2 downto 0) <= tileMem(to_integer(tileAddr))(10 downto 8);
      end if;
    end if;
  end process;
  --two
  process(clk)
  begin
    if rising_edge(clk) then
      if collision_reset = '1' then
        collision_two(3) <= '0';
      elsif collision_two(3) = '0' and transparent_two = '0' and tileMem(to_integer(tileAddr))(11) = '1' then
        collision_two(3) <= '1';
        collision_two(2 downto 0) <= tileMem(to_integer(tileAddr))(10 downto 8);
      end if;
    end if;
  end process;
                               
  -- Pixel MUX
  process(clk)
  begin
    if rising_edge(clk) then
      if blank = '0' then
        if transparent_one = '1' then
        --  if transparent_two = '1' then
            -- Choose the tile if no sprites are in front of it.
            outPixel <= tileMem(to_integer(tileAddr))(7 downto 0);            
         -- else
          --  outPixel <=  ballSprite(to_integer(addr_two))(7 downto 0);
          --end if;
        else
          outPixel <=  ballSprite(to_integer(addr_one))(7 downto 0);
        end if;
      else
        outPixel <= (others => '0');
      end if;
      
    end if;
  end process;

  
  

  

  
end Behavioral;

