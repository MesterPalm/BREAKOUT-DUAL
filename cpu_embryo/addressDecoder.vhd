library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity addressDecoder is
  port(addressIn : in std_logic_vector(31 downto 0);
       ASR : out std_logic_vector(31 downto 0);
       pictMemAddress : out std_logic_vector(10 downto 0));
end addressDecoder;
  constant spaceBorder : std_logic_vector(31 downto 0) := "00000000000000000000001111101000";  -- Border between picture memory and program memory

architecture Behavioral of addressDecoder is
begin  -- addressDecoder
  --Low spaceSelect means program memory and high spaceSelect means picture mempry
  if addressIn < spaceBorder then
    ASR <= addressIn; 
  elsif addressIn >= spaceBorder then
    pictMemAddress <= addressIn - spaceBorder;
  end if;
end Behavioral;
