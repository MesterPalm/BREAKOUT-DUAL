library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- instrDec interface
entity instrDec is
  port (
    instruction : in unsigned(31 downto 0);
    operand : out unsigned (31 downto 0);
    uAddr : out unsigned(6 downto 0);
    grA : out unsigned(3 downto 0);
    grB : out unsigned(3 downto 0);
    clk : std_logic);
end instrDec;

architecture Behavioral of instrDec is

begin  -- Behavioral
  process (clk)
  begin  -- microprogram select
    if rising_edge(clk) then
      case instruction(31 downto 27) is
        when b"00000" =>
          uAddr <= b"000_000_0";
        when b"00001" =>
          uAddr <= b"000_001_1";
        when b"00010" =>
          uAddr <= b"000_010_0";
        when others =>
          uAddr <= b"000_000_0";
      end case;
    end if;
  end process;

  process (clk)
  begin --format select 
    if rising_edge(clk) then
      if (instruction(31 downto 27) = "00010")
      then --FORMAT op-gra-grb
        grA <= instruction(26 downto 23);
        grB <= instruction(22 downto 19);
        operand <= "0000000000000"  & instruction(18 downto 0);
      elsif (false)
      then --FORMAT op-addM-operand
        grA <= "0000";
        grB <= "0000";
        --ADD ADDRESS MODE SELECT
        operand <= "0000000"  & instruction(24 downto 0);
      elsif (instruction(31 downto 27) = b"00001")
      then --FORMAT op-gra-addM-operand
        grA <= instruction(26 downto 23);
        grB <= "0000";
        --ADD ADDRESS MODE SELECT
        operand <= "00000000000" & instruction(20 downto 0);
      elsif((instruction(31 downto 27) = b"00000") or
            true)
      then--FORMAT op-operand
        grA <= "0000";
        grB <= "0000";
        operand <= "00000" & instruction(26 downto 0);
      end if;
    end if;
  end process;
end Behavioral;
