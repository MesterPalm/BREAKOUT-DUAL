-- entity
entity SPRITE_MEM is
  port ( clk		: in std_logic;
         -- port 1
         we1		: in std_logic;
         data_in1	: in std_logic_vector(7 downto 0);
         data_out1	: out std_logic_vector(7 downto 0);
         addr1		: in unsigned(10 downto 0);
         -- port 2
         we2		: in std_logic;
         data_in2	: in std_logic_vector(7 downto 0);
         data_out2	: out std_logic_vector(7 downto 0);
         addr2		: in unsigned(10 downto 0));
end SPRITE_MEM;

	
-- architecture
architecture Behavioral of SPRITE_MEM is

  type ball_t is array (0 to 7) of std_logic_vector(27 downto 0);    
  -- initiate picture memory to one cursor ("1F") followed by spaces ("00")
  signal spriteMem : ball_t := (others => (others => '0'));


begin

  process(clk)
  begin
    if rising_edge(clk) then
      if (we1 = '1') then
        spriteMem(to_integer(addr1)) <= data_in1;
      end if;
      data_out1 <= spriteMem(to_integer(addr1));
      
      if (we2 = '1') then
        spriteMem(to_integer(addr2)) <= data_in2;
      end if;
      data_out2 <= spriteMem(to_integer(addr2));
    end if;
  end process;


end Behavioral;
