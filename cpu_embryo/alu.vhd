library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- todo: ALU cheat sheet 

-- alu interface
entity alu is
    port(
      clk : in std_logic;
      alu_data : in unsigned(15 downto 0);
      alu_opcode : in unsigned (3 downto 0);
      ar : buffer unsigned (15 downto 0);
      status : out unsigned (7 downto 0));
end alu;

architecture Behavioral of alu is
  signal equal : std_logic;
	signal K_add : unsigned(15 downto 0);
	signal K_sub : unsigned(15 downto 0);
  
begin
  process(clk) begin
    if (rising_edge(clk)) then

      if alu_opcode = 1 then         -- add
        -- Overflow flag
				if ((ar(15) = alu_data(15)) and (K_add(15) /= ar(15))) then
					status(0) <= '1';
				else
					status(0) <= '0';
				end if;
        ar <= ar + alu_data;
      elsif alu_opcode = 2 then         -- sub
				-- set overflow flag
				if ((ar(15) = alu_data(15)) and (K_sub(15) /= ar(15))) then
					status(0) <= '1';
				else
					status(0) <= '0';
				end if;
				-- zero flag (when subtracting equal terms)
        status(1) <= equal;
        ar <= ar - alu_data;
			elsif alu_opcode = 3 then 				-- arithmetic/logic shift left
				ar <= ar(14 downto 0) & '0';
			elsif alu_opcode = 4 then 				-- arithmetic shift right
				ar <= ar(15) & ar(15 downto 1);
			elsif alu_opcode = 15 then 				-- set special flag
				status(7) <= '1';	
      else                              -- idle
        ar <= ar;
      end if;
    end if;
  end process;
	
	K_add <= ar + alu_data;
	K_sub <= ar - alu_data;
	equal <= '1' when (ar = alu_data) else '0';
                                      
                                      
                                         
                                       
  
end Behavioral;
