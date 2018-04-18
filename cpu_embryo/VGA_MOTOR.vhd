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
         -- one bit for each sprite so that we can se which ball colided.
         collision              : out std_logic_vector(1 downto 0);
         -- the normal that the ball colided with.
         normal                 : out std_logic_vector(2 downto 0);
         ball_one_pos           : out std_logic_vector(18 downto 0);
         ball_two_pos           : out std_logic_vector(18 downto 0)
         );
end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

  signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal
		
  signal 	tilePixel       : std_logic_vector(11 downto 0);	-- Tile pixel data
  signal	tileAddr	: unsigned(10 downto 0);	-- Tile address

  signal        blank           : std_logic;                    -- blanking signal
	

  -- Tile memory type
  type ram_t is array (0 to 2047) of std_logic_vector(11 downto 0);

-- Tile memory
-- colour chart http://www.fountainware.com/EXPL/vga_color_palettes.htm
  signal tileMem : ram_t := 
		( 
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",      -- blue
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
		  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",      -- blue
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
		  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",
                  x"037",x"037",x"037",x"037",x"037",x"037",x"037",x"037",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",

                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- space
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"004",x"004",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"004",x"004",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF"
                  
                  );
  
  -- Ball memory type
  type balls is array (0 to 63) of std_logic_vector(11 downto 0);

  signal ballSprite : bs := 
		( 
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- ball
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF"

                  );
  
  -- Paddle memory type
  type paddles is array (0 to 63) of std_logic_vector(11 downto 0);

  signal paddleSprite : paddles := 
		( 
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",      -- ball
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
		  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",
                  x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF",x"0FF"

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
  process(clk)
  begin
    if rising_edge(clk) then
      if (blank = '0') then
        tilePixel <= tileMem(to_integer(tileAddr))(11 downto 0);
      else
        tilePixel <= (others => '0');
      end if;
    end if;
  end process;


  -- Collision logic
  --collision <= '1' when (
	


  -- Tile memory address composite
  tileAddr <= unsigned(data(4 downto 0)) & Ypixel(4 downto 2) & Xpixel(4 downto 2);


  -- Picture memory address composite
  addr <= to_unsigned(20, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5);


  -- VGA generation
  vgaRed(2) 	<= tilePixel(7);
  vgaRed(1) 	<= tilePixel(6);
  vgaRed(0) 	<= tilePixel(5);
  vgaGreen(2)   <= tilePixel(4);
  vgaGreen(1)   <= tilePixel(3);
  vgaGreen(0)   <= tilePixel(2);
  vgaBlue(2) 	<= tilePixel(1);
  vgaBlue(1) 	<= tilePixel(0);

  -- normal generation
  normal(2) <= tilePixel(10);
  normal(1) <= tilePixel(9);
  normal(0) <= tilePixel(8);

  
  -----------------------------------------------------------------------------
  -- Start of K-nät for the muxing of tiles and sprites.
  -----------------------------------------------------------------------------
  ball_one_x <= ball_one_pos(18 downto 9);
  ball_one_y <= ball_one_pos(8 downto 0);
  delta_one_x <= ball_one_x - Xpixel;
  delta_one_y <= ball_one_y - Ypixel(8 downto 0);
  
  delta_adr <= current pixel adr - spriteadr;
  transparent <= '1' when delta_adr >= 0 and delta addr <= 63 and (not sprite(delta_adr)(transparentbit)) else '0';
  -- Do this for every sprite

  process(clk)
  begin
    if rising_edge(clk) then
      if (sprite_1_transparent) then
        if (sprite_2_transparent) then
          --...
          -- Choose the tile if no sprites are in front of it.
        else

        end if;
      else

      end if;
    end if;
  end process;
  

  

  
end Behavioral;

