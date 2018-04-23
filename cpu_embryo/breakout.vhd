library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--CPU interface
entity breakout is
  port(clk: in std_logic;
       btns: in std_logic;             --rst
       JA: out unsigned(1 downto 0); -- trigger
       JB: in unsigned(1 downto 0); -- echo
       Led : out unsigned(7 downto 0);
       seg : out unsigned (7 downto 0);
       an : out unsigned (3 downto 0);
       Hsync : out std_logic;                        -- horizontal sync
       Vsync : out std_logic;                        -- vertical sync
       vgaRed : out	std_logic_vector(2 downto 0);   -- VGA red
       vgaGreen : out std_logic_vector(2 downto 0);     -- VGA green
       vgaBlue : out std_logic_vector(2 downto 1);     -- VGA blue
       PS2KeyboardCLK	        : in std_logic;                         -- PS2 clock
       PS2KeyboardData        : in std_logic);                        -- PS2 data
end breakout ;

architecture Behavioral of breakout is


  -- micro Memory component
  component uMem
    port(uAddr : in unsigned(5 downto 0);
         uData : out unsigned(15 downto 0));
  end component;

  -- program Memory component
  component pMem
    port(pAddr : in unsigned(15 downto 0);
         pData : out unsigned(15 downto 0));
  end component;

  -- Ultra module component
  component ultra
    port(clk : in std_logic;
	 JA: out unsigned(1 downto 0); -- vcc, trigger, gnd
	 JB: in unsigned(1 downto 0); -- echo
	 us_time : buffer unsigned(15 downto 0);
         rst : in std_logic
    );
  end component;

   -- PS2 keyboard encoder component
  component KBD_ENC
    port ( clk		        : in std_logic;				-- system clock
	   rst		        : in std_logic;				-- reset signal
	   PS2KeyboardCLK       : in std_logic;				-- PS2 clock
	   PS2KeyboardData      : in std_logic;				-- PS2 data
	   data		        : out std_logic_vector(7 downto 0);	-- tile data
	   addr			: out unsigned(10 downto 0);	        -- tile address
	   we			: out std_logic);	                -- write enable
  end component;
  
  -- picture memory component
  component PICT_MEM
    port ( clk			: in std_logic;                         -- system clock
	 -- port 1
           we1		        : in std_logic;                         -- write enable
           data_in1	        : in std_logic_vector(7 downto 0);      -- data in
           data_out1	        : out std_logic_vector(7 downto 0);     -- data out
           addr1	        : in unsigned(10 downto 0);             -- address
	 -- port 2
           we2			: in std_logic;                         -- write enable
           data_in2	        : in std_logic_vector(7 downto 0);      -- data in
           data_out2	        : out std_logic_vector(7 downto 0);     -- data out
           addr2		: in unsigned(10 downto 0));            -- address
  end component;
	
  -- VGA motor component
  component VGA_MOTOR is
  port ( clk			: in std_logic;
	 data			: in std_logic_vector(7 downto 0);
	 addr			: out unsigned(10 downto 0);
	 rst			: in std_logic;
	 vgaRed		        : out std_logic_vector(2 downto 0);
	 vgaGreen	        : out std_logic_vector(2 downto 0);
	 vgaBlue		: out std_logic_vector(2 downto 1);
	 Hsync		        : out std_logic;
	 Vsync		        : out std_logic;
         -- first bit 1 if collision, 3-bit enumerated normal.
         collision_one          : buffer unsigned(3 downto 0);
         collision_two          : buffer unsigned(3 downto 0);
         -- The balls start_stop X and start_stop Y.
         ball_one_posX          : in unsigned(9 downto 0);
         ball_one_posY          : in unsigned(9 downto 0);
         ball_two_posX          : in unsigned(9 downto 0);
         ball_two_posY          : in unsigned(9 downto 0);
         collision_reset        : in std_logic
         
         );
end component;

  -- Led driver for debugging
  --component leddriver
  --  Port ( clk,rst : in  STD_LOGIC;
  --         seg : out  UNSIGNED(7 downto 0);
  --         value : in  UNSIGNED (3 downto 0));
  --end component;

  component leddriver
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  UNSIGNED(7 downto 0);
           an : out  UNSIGNED (3 downto 0);
           value : in  UNSIGNED (15 downto 0)
           );
  end component;

  -- micro memory signals
  signal uM : unsigned(15 downto 0); -- micro Memory output
  signal uPC : unsigned(5 downto 0); -- micro Program Counter
  signal uPCsig : std_logic; -- (0:uPC++, 1:uPC=uAddr)
  signal uAddr : unsigned(5 downto 0); -- micro Address
  signal TB : unsigned(2 downto 0); -- To Bus field
  signal FB : unsigned(2 downto 0); -- From Bus field
	
  -- program memory signals
  signal PM : unsigned(15 downto 0); -- Program Memory output
  signal PC : unsigned(15 downto 0); -- Program Counter
  signal Pcsig : std_logic; -- 0:PC=PC, 1:PC++
  signal ASR : unsigned(15 downto 0); -- Address Register
  signal IR : unsigned(15 downto 0); -- Instruction Register
  signal DATA_BUS : unsigned(15 downto 0); -- Data Bus

  --code for the hexdisplay
  signal HEX : unsigned (3 downto 0);
--  signal hex_mux : unsigned (1 downto 0);
--  signal seg : unsigned (6 downto 0);
--  signal an : unsigned (3 downto 0);
  -- ultra beahvior signals
  signal us_time_temp  : unsigned(15 downto 0);
  signal counter_temp : unsigned(23 downto 0);
  
  signal us_time : unsigned (15 downto 0);
  signal rst : std_logic;


  --VGA_MOTOR
  -- intermediate signals between KBD_ENC and PICT_MEM
  signal        data_s	        : std_logic_vector(7 downto 0);         -- data
  signal	addr_s	        : unsigned(10 downto 0);                -- address
  signal	we_s		: std_logic;                            -- write enable
	
  -- intermediate signals between PICT_MEM and VGA_MOTOR
  signal	data_out2_s     : std_logic_vector(7 downto 0);         -- data
  signal	addr2_s		: unsigned(10 downto 0);                -- address

  -- intermediate signals between VGA_MOTOR and ALU / other component
  signal        collision_s     : std_logic;
  signal        normal_s        : std_logic_vector(2 downto 0);

  signal collision_one_s          : unsigned(3 downto 0);
  signal collision_two_s          : unsigned(3 downto 0);
         -- The balls start_stop X and start_stop Y.
  signal ball_one_posX_s         : unsigned(9 downto 0);
  signal ball_one_posY_s          : unsigned(9 downto 0);
  signal ball_two_posX_s          : unsigned(9 downto 0);
  signal ball_two_posY_s          : unsigned(9 downto 0);
  signal collision_reset_s        : std_logic;
  
begin
  rst <= btns;
  Led(1) <= btns;
  
  -- mPC : micro Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        uPC <= (others => '0');
      elsif (uPCsig = '1') then
        uPC <= uAddr;
      else
        uPC <= uPC + 1;
      end if;
    end if;
  end process;
	
  -- PC : Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        PC <= (others => '0');
      elsif (FB = "011") then
        PC <= DATA_BUS;
      elsif (PCsig = '1') then
        if PC < 15  then
          PC <= PC + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- IR : Instruction Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');
      elsif (FB = "001") then
        IR <= DATA_BUS;
      end if;
    end if;
  end process;
	
  -- ASR : Address Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');
      elsif (FB = "100") then
        ASR <= DATA_BUS;
      end if;
    end if;
  end process;
 -- processorn inte redo för att ta in saker på bussen såhär
 -- interupts behövs.
 -- process (clk)
--  begin
    --if rising_edge(clk) then
     -- if (rst = '1') then
      --  HEX <= "0000";
     -- elsif (FB = "110") then
      --  HEX <= DATA_BUS(3 downto 0);
    --  end if;
  --  end if;
--  end process;

  Led(0) <= '1' when (us_time > 750) else '0';
	
  -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- program memory component connection
  U1 : pMem port map(pAddr=>ASR, pData=>PM);

  UL : ultra port map(clk, JA, JB, us_time, rst);

   -- picture memory component connection
  U3 : PICT_MEM port map(clk=>clk, we1=>we_s, data_in1=>data_s, addr1=>addr_s, we2=>'0', data_in2=>"00000000", data_out2=>data_out2_s, addr2=>addr2_s);
	
  -- VGA motor component connection
  U4 : VGA_MOTOR port map(clk=>clk, rst=>rst, data=>data_out2_s, addr=>addr2_s, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync, collision_one=>collision_one_s, collision_two=>collision_two_s, ball_one_posX=>ball_one_posX_s, ball_one_posY=>ball_one_posY_s, ball_two_posX=>ball_two_posX_s, ball_two_posY=>ball_two_posY_s, collision_reset=>collision_reset_s);

  -- keyboard encoder component connection
  U5 : KBD_ENC port map(clk=>clk, rst=>rst, PS2KeyboardCLK=>PS2KeyboardCLK, PS2KeyboardData=>PS2KeyboardData, data=>data_s, addr=>addr_s, we=>we_s);

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        counter_temp <= X"000000";
        led(2) <= '1';
        led(3) <= '0';
        led(4) <= '0';
      else
        if counter_temp = X"000000" then
          us_time_temp <= us_time;
          counter_temp <= counter_temp + 1;
          led(2) <= '0';
          led(3) <= '1';
          led(4) <= '0';
        else
          --us_time_temp <= X"DEF3";
          counter_temp <= counter_temp + 1;
          led(2) <= '0';
          led(3) <= '0';
          led(4) <= '1';
        end if;
      end if;
     
    end if;
  end process;
  -- Plug in the led driver
  HD: leddriver port map (clk, rst, seg, an, value=>us_time_temp);

  -- micro memory signal assignments
  uAddr <= uM(5 downto 0);
  uPCsig <= uM(6);
  PCsig <= uM(7);
  FB <= uM(10 downto 8);
  TB <= uM(13 downto 11);
	
  -- data bus assignment
  DATA_BUS <= IR when (TB = "001") else
    PM when (TB = "010") else
    PC when (TB = "011") else
    ASR when (TB = "100") else
    us_time when (TB = "101") else
   (others => '0');

end Behavioral;
