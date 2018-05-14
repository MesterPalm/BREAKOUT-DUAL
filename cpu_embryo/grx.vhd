library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- grx interface
entity grx is
  port (
    grxAddr : in unsigned(3 downto 0);
    grxDataIn : in unsigned(31 downto 0);
    grxDataOut : out unsigned(31 downto 0);
    grxRW : in std_logic; --the read/write bit, in read mode when high else write
    clk : in std_logic);
end grx;

architecture Behavioral of grx is

type grx_t is array (0 to 15) of unsigned(31 downto 0);

constant grx_c : grx_t :=
  (X"0000_0000", 
   X"0000_0000", 
   X"0000_0000", 
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000",
   X"0000_0000");

signal grx : grx_t := grx_c;

begin  -- Behavioral
  process (grxAddr, grxRW) begin
     --if rising_edge(clk) then
      if (grxRW = '1') then
        grxDataOut <= grx(to_integer(grxAddr));
      elsif (grxRW = '0') then
        grx(to_integer(grxAddr)) <= grxDataIn;
      end if;
    --end if;
  end process;
end Behavioral;
