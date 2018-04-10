library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- grx interface
entity grx is
  port (
    grxAddr : in unsigned(6 downto 0);
    grxDataIn : in unsigned(15 downto 0);
    grxDataOut : out unsigned(15 downto 0);
    grxRW : in std_logic; --the read/write bit, in read mode when high else write
    clk : in std_logic);
end grx;

architecture Behavioral of grx is

type grx_t is array (0 to 15) of unsigned(15 downto 0);

signal grx_c : grx_t :=
   --OP_TB_FB_PC_uPC_uAddr
   --4__4__4__1__3___7
  (b"0000_0000_0000_0000", -- ASR:=PC, Next Instruction start
   b"0000_0000_0000_0000", -- IR:=PM, PC:=PC+1
   b"0000_0000_0000_0000", -- , JMP Start
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000",
   b"0000_0000_0000_0000");

begin  -- Behavioral
  process (clk) begin
    if rising_edge(clk) then
      if (grxRW = '1') then
        grxDataOut <= grx_c(to_integer(grxAddr));
      else
        grx_c(to_integer(grxAddr)) <= grxDataIn;
      end if;
    end if;
  end process;
end Behavioral;
