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
    clk : in std_logic;
    ballx1 : out unsigned(9 downto 0);
    bally1 : out unsigned(9 downto 0);
    ballx2 : out unsigned(9 downto 0);
    bally2 : out unsigned(9 downto 0);
    collision1 : in unsigned(3 downto 0);
    collision2 : in unsigned(3 downto 0);
    collisAddr1 : in unsigned(10 downto 0);
    collisAddr2 : in unsigned(10 downto 0);
    paddle1 : in unsigned(9 downto 0);
    paddle2 : in unsigned(9 downto 0);
    alreadyCollided : out unsigned(1 downto 0) 
    );
end grx;

architecture Behavioral of grx is

type grx_RW is array (0 to 8) of unsigned(31 downto 0);
type grx_RO is array(9 to 14) of unsigned(31 downto 0);

signal grx_RW_s : grx_RW;
signal grx_RO_s : grx_RO;
signal index : unsigned(31 downto 0);

begin -- Behavioral
  -- read write special registers 6 to 8
  alreadyCollided <= grx_RW_s(6)(1 downto 0);
  ballx1 <= grx_RW_s(7)(31 downto 22);
  bally1 <= grx_RW_s(7)(21 downto 12);
  ballx2 <= grx_RW_s(8)(31 downto 22);
  bally2 <= grx_RW_s(8)(21 downto 12);
  -- read only special registrer 9 to 14
  grx_RO_s(9)  <= "0000000000000000000000" & paddle1;
  grx_RO_s(10) <= "0000000000000000000000" & paddle2;
  
  grx_RO_s(11) <= x"0000_000" & collision1;
  grx_RO_s(12) <= x"0000_000" & collision2;

  grx_RO_s(13) <= "000000000000000000000" & collisAddr1;
  grx_RO_s(14) <= "000000000000000000000" & collisAddr2;
  
  grxDataOut <= index when (grxRW = '1' and grxAddr = 15) else
                grx_RO_s(to_integer(grxAddr)) when (grxRW = '1' and grxAddr > 8) else
                grx_RW_s(to_integer(grxAddr)) when (grxRW = '1') else
                (others => '0');
  
  process (clk)
  begin
    if (rising_edge(clk)) then     
      if (grxRW = '0') then
        if grxAddr = 15 then
          index <= grxDataIn;
        else
          grx_RW_s(to_integer(grxAddr)) <= grxDataIn;
        end if;
      end if;
    end if;
  end process;
end Behavioral;
