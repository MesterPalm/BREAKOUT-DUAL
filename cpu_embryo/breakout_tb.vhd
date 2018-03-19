LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY breakout_tb IS
END breakout_tb;

ARCHITECTURE behavior OF breakout_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT breakout
  PORT(clk : IN std_logic;
       rst : IN std_logic;
       JA: out unsigned(1 downto 0); -- trigger
       JB: in unsigned(1 downto 0); -- echo
       Led : out unsigned(1 downto 0));
  END COMPONENT;

  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';
  signal JA : unsigned(1 downto 0);
  signal JB : unsigned(1 downto 0);
  signal Led : unsigned(1 downto 0);
  
  --Clock period definitions
  constant clk_period : time:= 10 ns;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: breakout PORT MAP (
    clk => clk,
    rst => rst,
    JA => JA,
    JB => JB,
    Led => Led
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

