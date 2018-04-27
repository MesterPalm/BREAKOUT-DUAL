library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- todo: ALU cheat sheet 

-- alu interface
entity alu is
    port(
      clk : in std_logic;
      alu_data : in unsigned(31 downto 0);
      alu_opcode : in unsigned (3 downto 0);
      ar : buffer unsigned (31 downto 0);
      status : out unsigned (7 downto 0));
end alu;

architecture Behavioral of alu is
  signal equal : std_logic;
  signal K_add : unsigned(31 downto 0);
  signal K_sub : unsigned(31 downto 0);
  signal normal : unsigned (2 downto 0); -- Collision normal vector
	signal ball_v : unsigned (2 downto 0); -- Ball velocity vector
	signal reflected : unsigned (2 downto 0); -- Reflected velocity vector 
	signal diff : unsigned (2 downto 0); 	-- Reflection diff (to determine whether to reflect)
  
begin
  process(clk, normal, ball_v) begin
    if (rising_edge(clk)) then
			if alu_opcode = 1 then 					-- Place data in AR
				ar <= alu_data;
      elsif alu_opcode = 2 then       -- add
        -- Overflow flag
        if ((ar(31) = alu_data(31)) and (K_add(31) /= ar(31))) then
          status(0) <= '1';
				else
	 			 status(0) <= '0';
				end if;
        ar <= ar + alu_data;
      elsif alu_opcode = 3 then         -- sub
        -- set overflow flag
        if ((ar(31) = alu_data(31)) and (K_sub(31) /= ar(31))) then
          status(0) <= '1';
        else
          status(0) <= '0';
        end if;
        -- zero flag (when subtracting equal terms)
        status(1) <= equal;
        ar <= ar - alu_data;
      elsif alu_opcode = 4 then 				-- arithmetic/logic shift left
        ar <= ar(30 downto 0) & '0';
      elsif alu_opcode = 5 then 				-- arithmetic shift right
        ar <= ar(31) & ar(31 downto 1);
      elsif alu_opcode = 6 then         -- vector reflection
				if diff > 2 then
        	ar <= ar(31 downto 3) & ball_v; -- TODO: make coherent with actual ball-reg structure
				else
        	ar <= ar(31 downto 3) & reflected; -- TODO: make coherent with actual ball-reg structure
				end if;

        
      elsif alu_opcode = 15 then 				-- set special flag
        status(7) <= '1';	
      else                              -- idle
        ar <= ar;
      end if;
    end if;
  end process;

	normal <= ar(2 downto 0); -- Assumes AR holds normal as 3 least sigbits
	ball_v <= alu_data(2 downto 0); -- Same assumption
	diff <= 5 + normal - ball_v;
	reflected <= 4 - ball_v + normal + normal;
  K_add <= ar + alu_data;
  K_sub <= ar - alu_data;
  equal <= '1' when (ar = alu_data) else '0';

end Behavioral;
