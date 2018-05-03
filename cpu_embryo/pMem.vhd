library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- pMem interface
entity pMem is
  port(
    pAddr : in unsigned(31 downto 0);
    pData : out unsigned(31 downto 0));
end pMem;

architecture Behavioral of pMem is

-- program Memory
type p_mem_t is array (0 to 15) of unsigned(31 downto 0);
constant p_mem_c : p_mem_t :=
  (b"00010_01_0011_000000000000000000000",  --0   --LOAD DIREKT GR11     
   b"00000_00_0000000000000000000001000",  --1   --dec(8)      
   b"00010_01_0100_000000000000000000000",  --10  --LOAD DIREKT GR7
   b"00000_000000000000000000000000001",  --11  --dec(5)
   b"00100_00_0011_0100_00000000000000000",  --100 --SUB GR11 GR7
   b"00011_00_0100_0000_00000000000000000",  --101
   b"00000_00_00_00_00_0000000000000000000",  --110        
   b"00000_00_0000000000000000000000000",  --111
   b"00000_00_0000000000000000000000000", --1000  
   b"00000_00_0000000000000000000000000",  --1001      
   b"00000_00_0000000000000000000000000",  --1010     
   b"00000_00_0000000000000000000000000",  --1011
   b"00000_00_0000000000000000000000000",  --1100
   b"00000_00_0000000000000000000000000",  --1101
   b"00001_01_0000000000000000000000000",  --1110   
   b"00000_00_0000000000000000000000000"); --1111

  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData <= p_mem(to_integer(pAddr));

end Behavioral;
