
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- pMem interface
entity pMem is
  port(
    pAddr : in unsigned(31 downto 0);
    pDataOut : out unsigned(31 downto 0);
    pDataIn : in unsigned(31 downto 0);
    readWrite: in std_logic);
end pMem;

architecture Behavioral of pMem is

-- program Memory
type p_mem_t is array (0 to 34) of unsigned(31 downto 0);
constant p_mem_c : p_mem_t :=
  (x"0000_0000",                                --0
   b"00010_01_0010_0000_00000000000000000",     --1
   x"0000_0008",                                --2
   b"00010_01_1111_0000_00000000000000000",     --3
   x"0000_0000",                                --4
   b"00010_01_0100_0000_00000000000000000",     --5
   x"0000_0001",                                --6
   b"00011_00_1111_0100_00000000000000000",  --add --7
   b"00111_00_1111_0010_00000000000000000", --CMP --8
   b"00110_01_0000_0000_00000000000000000", --BEQ --9
   b"00000_00_0000_0000_00000000000000000",  --a
   b"00010_11_0111_0000_00000000000001110",  --b
   b"01000_10_0111_0000_00000001111101011",  --c
   b"00001_01_0000_0000_00000000000000000", --BRA --d
   x"0000_001b",                        --e
   x"0000_000a",                        --f
   x"0000_000b",                        --10
   x"0000_000c",                        --11
   x"0000_000d",                        --12
   x"0000_000e",                        --13
   x"0000_000f",                        --14
   x"0000_0010",                        --15
   x"0000_0011",                        --16
   x"0000_0012",                        --17
   x"0000_0013",                        --18
   x"0000_0014",                        --19
   x"0000_0015",                        --1a
   b"00010_01_0101_0000_00000000000000000", --1b
   x"000A_AAAA",                        --1c
   b"00100_00_0101_0100_00000000000000000",  --1d
   b"00111_00_0101_0100_00000000000000000",  --1e
   b"00110_01_0000_0000_00000000000000000",
   x"0000_0007",
   b"00001_01_0000_0000_00000000000000000", --BRA
   x"0000_001c"
   );

   signal p_mem : p_mem_t := p_mem_c;

begin  -- pMem
  -- purpose: data in or data out 
  process (readWrite, pAddr)
  begin  -- process
    if (readWrite = '1') then
       pDataOut <= p_mem(to_integer(pAddr));
    elsif (readWrite = '0') then
      p_mem(to_integer(pAddr)) <= pDataIn;
    end if;
  end process;
 
end Behavioral;
