library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- uMem interface
entity uMem is
  port (
    uAddr : in unsigned(6 downto 0);
    uData : out unsigned(24 downto 0));
end uMem;

architecture Behavioral of uMem is

-- micro Memory
type u_mem_t is array (0 to 19) of unsigned(24 downto 0);
constant u_mem_c : u_mem_t :=
   --OP_TB_FB_PC_S_grA/B_uPC_uAddr
   --4__4__4__1_1__3___7
  (b"0000_0011_0100_0_0_0_000_0000000", -- ASR := PC, Next Instruction start
   b"0000_0010_0001_1_0_0_000_0000000", -- IR := PM, PC := PC+1
   b"0000_0000_0000_0_0_0_011_0000000", -- uPc := uMode 
   b"0000_0000_0000_0_0_0_010_0000000", -- ADDRESS-MODE 00/NOLLADRESSERING
   b"0000_0011_0100_1_0_0_010_0000000", -- ASR := PC; PC := PC+1;uPc := uProg    ADRESS-MODE 01/DIREKT
   b"0000_1001_0100_0_0_0_010_0000000", -- ASR := uOperand; uPC:=uProg         ADRESS-MODE 10/
   b"0001_1001_1000_0_0_0_000_0000000", -- AR := uOperand ADRESS-MODE 11/ 
   b"1000_0101_1000_0_0_1_000_0000000", -- AR := GR15 + AR;
   b"0000_0111_0100_0_0_0_010_0000000", -- ASR := AR; uPC:=uProg
   b"0000_0010_0101_0_0_0_001_0000000", -- GRX := PM; LOAD
   b"0000_0010_0011_0_0_0_001_0000000", -- PC := PM; BRA
   b"0000_0101_1000_0_0_0_000_0000000", -- AR := GRA; ADD BEGIN 
   b"1000_0101_1000_0_0_1_000_0000000", -- AR := AR+GRB
   b"0000_0111_0101_0_0_0_001_0000000", --GRA := AR; ADD END
   b"0001_0101_1000_0_0_0_000_0000000", --AR := GRA; SUB BEGIN
   b"0010_0101_1000_0_0_1_000_0000000", --AR := AR-GRB;
   b"0000_0111_0101_0_0_0_001_0000000", --GRA := AR; SUB END
   b"0001_0101_1000_0_0_1_000_0000000", --AR := GRB;MOV BEGIN
   b"0000_0111_0101_0_0_0_001_0000000", --GRA := AR;MOV END
   b"0000_0000_0000_0_0_0_000_0000000"); 
 --b"0000_0000_0000_0_0_0_000_0000000"--

signal u_mem : u_mem_t := u_mem_c;

begin  -- Behavioral
  uData <= u_mem(to_integer(uAddr));

end Behavioral;
