library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity PICT_MEM is
  port ( clk		: in std_logic;
         -- port 1
         we1		: in std_logic;
         data_in1	: in unsigned(7 downto 0);
         data_out1	: out unsigned(7 downto 0);
         addr1		: in unsigned(10 downto 0);
         -- port 2
         we2		: in std_logic;
         data_in2	: in unsigned(7 downto 0);
         data_out2	: out unsigned(7 downto 0);
         addr2		: in unsigned(10 downto 0));
end PICT_MEM;

	
-- architecture
architecture Behavioral of PICT_MEM is

  type ram_t is array (0 to 299) of unsigned(7 downto 0);    
  signal pictMem : ram_t :=
                            (
-- Initial level here.
x"0a",x"0a",x"0a",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"0f",x"0b",x"0b",x"0b",x"0b",x"0b",x"0b",x"0b",x"0e",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"0f",x"0e",x"00",x"0b",x"0b",x"10",x"10",x"10",x"10",x"10",x"0b",x"0b",x"00",x"0f",x"0e",x"13", 
x"00",x"00",x"00",x"12",x"0b",x"0b",x"00",x"0b",x"0b",x"10",x"11",x"0b",x"11",x"10",x"0b",x"0b",x"00",x"0b",x"0b",x"13", 
x"00",x"00",x"00",x"12",x"0d",x"0c",x"00",x"0b",x"0b",x"10",x"10",x"10",x"10",x"10",x"0b",x"0b",x"00",x"0d",x"0c",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"0d",x"0b",x"0b",x"0b",x"0b",x"0b",x"0b",x"0b",x"0c",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"00",x"00",x"00",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13", 
x"0a",x"0a",x"0a",x"12",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"13"
                             );

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if (we1 = '1') then
        pictMem(to_integer(addr1)) <= data_in1;
      end if;
      data_out1 <= pictMem(to_integer(addr1));
      
      if (we2 = '1') then
        pictMem(to_integer(addr2)) <= data_in2;
      end if;
      data_out2 <= pictMem(to_integer(addr2));
    end if;
  end process;


end Behavioral;

