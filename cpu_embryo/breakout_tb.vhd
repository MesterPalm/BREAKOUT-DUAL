LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY breakout_tb IS
END breakout_tb;

ARCHITECTURE behavior OF breakout_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT breakout
  PORT(clk: in std_logic;
       btns: in std_logic;             --rst
       JA: out unsigned(1 downto 0); -- trigger
       JB: in unsigned(1 downto 0); -- echo
 --      Led : out unsigned(7 downto 0);
 --      seg : out unsigned (7 downto 0);
 --      an : out unsigned (3 downto 0);
       Hsync : out std_logic;                        -- horizontal sync
       Vsync : out std_logic;                        -- vertical sync
       vgaRed : out std_logic_vector(2 downto 0);   -- VGA red
       vgaGreen : out std_logic_vector(2 downto 0);     -- VGA green
       vgaBlue : out std_logic_vector(2 downto 1);     -- VGA blue
       PS2KeyboardCLK : in std_logic;                         -- PS2 clock
       PS2KeyboardData : in std_logic;
       btnu:std_logic;
       btnd:std_logic);
  END COMPONENT;

  --Inputs
  signal clk: std_logic;
  signal rst: std_logic;             --rst
  signal JA: unsigned(1 downto 0); -- trigger
  signal JB: unsigned(1 downto 0); -- echo
--  signal Led : unsigned(7 downto 0);
--  signal seg : unsigned (7 downto 0);
--  signal an : unsigned (3 downto 0);
  signal Hsync : std_logic;                        -- horizontal sync
  signal Vsync : std_logic;                        -- vertical sync
  signal vgaRed : std_logic_vector(2 downto 0);   -- VGA red
  signal vgaGreen : std_logic_vector(2 downto 0);     -- VGA green
  signal vgaBlue : std_logic_vector(2 downto 1);     -- VGA blue
  signal PS2KeyboardCLK : std_logic;                         -- PS2 clock
  signal PS2KeyboardData : std_logic;        
  
  --Clock period definitions
  constant clk_period : time:= 10 ns;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: breakout PORT MAP (
    clk => clk,
    btns => rst,
    JA => JA,
    JB => JB,
--    Led => Led,
--    seg => seg,
--    an => an,
    Hsync => Hsync,
    Vsync => Vsync,
    vgaRed => vgaRed,
    vgaGreen => vgaGreen,
    vgaBlue => vgaBlue,
    PS2KeyboardCLK => PS2KeyboardCLK,
    PS2KeyboardData=>PS2KeyboardData,
    btnu=>'0',
    btnd=>'0'
  );
		
  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
  JB <= "00", "01" after 40 us, "00" after 150us;
	rst <= '1', '0' after 1.7 us;
END;

