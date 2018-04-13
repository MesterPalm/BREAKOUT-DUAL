library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- instrDec interface
entity instrDec is
  port (
    instruction : in unsigned(15 downto 0);
    uAddr : out unsigned(6 downto 0);
    grA : out unsigned(6 downto 0);
    grB : out unsigned(6 downto 0));
end instrDec;

architecture Behavioral of instrDec is

begin  -- Behavioral
  uAddr <= b"000_000_0" when (instruction(15 downto 12) = X"0") else
           b"000_001_1" when (instruction(15 downto 12) = X"1") else
           b"000_010_0" when (instruction(15 downto 12) = X"2") else
           b"000_000_0" when (instruction(15 downto 12) = X"3") else
           (others => '0');

  grA <= instruction(11 downto 5);
  grB <= instruction(11 downto 5);

end Behavioral;
