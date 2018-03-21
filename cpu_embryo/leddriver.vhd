library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity leddriver is
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  UNSIGNED(7 downto 0);
           value : in  UNSIGNED (3 downto 0));
end leddriver;

architecture Behavioral of leddriver is
	signal segments : UNSIGNED (6 downto 0);
	signal v : UNSIGNED (3 downto 0);
        signal dp : STD_LOGIC;
begin
  -- decimal point not used
  dp <= '1';
  seg <= (dp & segments);
  v <= value;
   process(clk) begin
     if rising_edge(clk) then 
       case v is
         when "0000" => segments <= "0000001";
         when "0001" => segments <= "1001111";
         when "0010" => segments <= "0010010";
         when "0011" => segments <= "0000110";
         when "0100" => segments <= "1001100";
         when "0101" => segments <= "0100100";
         when "0110" => segments <= "0100000";
         when "0111" => segments <= "0001111";
         when "1000" => segments <= "0000000";
         when "1001" => segments <= "0000100";
         when "1010" => segments <= "0001000";
         when "1011" => segments <= "1100000";
         when "1100" => segments <= "0110001";
         when "1101" => segments <= "1000010";
         when "1110" => segments <= "0110000";
         when others => segments <= "0111000";
       end case;     
     end if;
   end process;
	
end Behavioral;

