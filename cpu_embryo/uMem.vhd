library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- uMem interface
entity uMem is
  port (
    uAddr : in unsigned(6 downto 0);
    uData : out unsigned(22 downto 0));
end uMem;

architecture Behavioral of uMem is

-- micro Memory
type u_mem_t is array (0 to 15) of unsigned(22 downto 0);
constant u_mem_c : u_mem_t :=
   --OP_TB_FB_PC_uPC_uAddr
   --4__4__4__1__3___7
  (b"0000_0011_0100_0_000_0000000", -- ASR:=PC, Next Instruction start
   b"0000_0010_0001_1_000_0000000", -- IR:=PM, PC:=PC+1
   b"0000_0000_0000_0_010_0000000", -- uPC:=uProg
   b"0000_0101_0011_0_001_0000000", -- PC:=GRA, JMP START and END
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000", 
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000",
   b"0000_0000_0000_0_000_0000000");
 --b"0000_0000_0000_0_000_0000000"--

signal u_mem : u_mem_t := u_mem_c;

begin  -- Behavioral
  uData <= u_mem(to_integer(uAddr));

end Behavioral;
