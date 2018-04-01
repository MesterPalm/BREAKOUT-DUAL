library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- todo: ALU cheat sheet 

-- alu interface
entity alu is
    port(
      clk : in std_logic;
      alu_data : in unsigned(15 downto 0);
      alu_opcode : in unsigned (3 downto 0));
      ar : out unsigned (15 downto 0);
      status : out unsigned 7 downto 0);
end alu;

architecture Behavioral of alu is
  signal equal : std_logic;
  signal K_add : unsigned(15 downto 0);
  signal K_sadd : unsigned(15 downto 0);  -- "special add" proof of concept
  
begin
  process(clk) begin
    if (rising_edge(clk)) then

      if alu_opcode = 1 then         -- add
        -- Overflow flag
        status(0) <= '1' if (
          ((ar(15) = alu_data(15)) and (alu_data(15) /= K_add(15)))
          ) else '0';
         ar <= K_add;        
      elsif alu_opcode = 2 then         -- sub
        status(1) <= '1' if (equal = '1') else '0';
        ar <= K_sub;
      else                              -- idle
        ar <= ar;
      end if;
    end if;
  end process;

  K_add <= ar + alu_data;
  K_sub <= ar - alu_data;
  equal <= '1' if (ar = alu_data) else '0';
  
end Behavioral;
