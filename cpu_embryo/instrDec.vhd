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
  uAddr <= b"000_000_0" when (instruction = X"0042") else
           b"000_000_0" when (instruction = X"00A0") else
           b"000_000_0" when (instruction = X"70FF") else
           b"000_001_1" when (instruction = X"1337") else
           (others => '0');

  grA <= b"000_000_0";
  grB <= b"000_000_1";

end Behavioral;
