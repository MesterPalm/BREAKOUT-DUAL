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
    grB : out unsigned(3 downto 0));
end instrDec;

architecture Behavioral of instrDec is

begin
  process (instruction)
  begin  --format select
    case instruction(31 downto 27) is
      when "00011" | "00100" | "00101" | "00111" | "10001" =>      --FORMAT op-addM-gra-grb-operand
        grA <= instruction(24 downto 21);
        grB <= instruction(20 downto 17);
        operand <= "000000000000000"  & instruction(16 downto 0);
        
      when "00010" | "01000" | "01010" | "01011" |
           "01101" | "01110" | "01111" | "10000" | "10010" =>  --FORMAT op-addM-gra-operand
        grA <= instruction(24 downto 21);
        grB <= "0000";
        operand <= "00000000000" & instruction(20 downto 0);
     -- when "10" =>                           --FORMAT op-operand
       --  grA <= "0000";
       --  grB <= "0000";
     --    operand <= "00000" & instruction(26 downto 0);
    when others =>--"00001" "01001" "01100"  "10011"           --FORMAT op-addM-operand
        grA <= "0000";
        grB <= "0000";
        operand <= "0000000" & instruction(24 downto 0);
    end case;
  end process;

  --Instruction select
  with instruction(31 downto 27) select
    uProg <= 
    b"000_000_0" when "00000",
    b"000_101_0" when "00001",          --BRA
    b"000_100_1" when "00010",          --LOAD
    b"000_101_1" when "00011",          --ADDR
    b"000_111_0" when "00100",          --SUBR
    b"001_000_1" when "00101",          --MOV
    b"001_001_1" when "00110",          --BEQ
    b"001_010_1" when "00111",          --CMP
    b"001_011_1" when "01000",          --STORE
    b"001_100_0" when "01001",          --BNE
    b"001_101_0" when "01010",          --ASL
    b"001_110_0" when "01011",          --ASR
    b"001_111_0" when "01100",          --BMI
    b"010_000_0" when "01101",          --ADD
    b"010_001_1" when "01110",          --SUB
    b"010_011_0" when "01111",          --AND
    b"010_100_1" when "10000",          --OR
    b"010_110_0" when "10001",          --REF
    b"010_111_1" when "10010",          --UPD
    b"011_000_1" when "10011",          --BRT
    b"000_000_0" when others;

  --Addressing mode select
  with instruction(26 downto 25) select
    uMode <=
    b"000_001_1" when "00",
    b"000_010_0" when "01",
    b"000_010_1" when "10",
    b"000_011_0" when "11",
    b"000_000_0" when others;
  
end Behavioral;
