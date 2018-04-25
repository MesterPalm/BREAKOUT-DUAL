library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- instrDec interface
entity instrDec is
  port (
    instruction : in unsigned(31 downto 0);
    operand : out unsigned (31 downto 0);
    uMode : out unsigned(6 downto 0);
    uProg : out unsigned(6 downto 0);
    grA : out unsigned(3 downto 0);
    grB : out unsigned(3 downto 0);
    clk : std_logic);
end instrDec;

architecture Behavioral of instrDec is

begin
  process (instruction)
  begin  --format select
    case instruction(31 downto 27) is
      when "00010" =>                          --FORMAT op-gra-grb
        grA <= instruction(26 downto 23);
        grB <= instruction(22 downto 19);
        operand <= "0000000000000"  & instruction(18 downto 0);
      when "00011" | "01000" =>                 --FORMAT op-addM-operand
        grA <= "0000";
        grB <= "0000";
        operand <= "0000000"  & instruction(24 downto 0);
      when "00001" =>                            --FORMAT op-addM-gra-operand
        grA <= instruction(24 downto 21);
        grB <= "0000";
        operand <= "00000000000" & instruction(20 downto 0);
      when others =>                            --FORMAT op-operand
        grA <= "0000";
        grB <= "0000";
        operand <= "00000" & instruction(26 downto 0);
    end case;
  end process;

  --Instruction select
  with instruction(31 downto 27) select
    uProg <= 
    b"000_000_0" when "00000",
    b"000_001_1" when "00001",
    b"000_000_0" when others;

  --Addressing mode select
  with instruction(26 downto 25) select
    uMode <=
    b"000_000_0"    when "00",
    b"000_000_0" when "01",
    b"000_000_0" when "10",
    b"000_000_0" when "11",
    b"000_000_0" when others;
  
end Behavioral;
