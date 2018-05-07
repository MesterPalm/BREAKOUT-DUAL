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
  --instruction decoder component
  component instrDec
    port (
      instruction : in unsigned(31 downto 0);
      operand : out unsigned(31 downto 0);
      uMode : out unsigned(6 downto 0);
      uProg : out unsigned(6 downto 0);
      grA : out unsigned(3 downto 0);
      grB : out unsigned(3 downto 0));
  end component;
  
  -- general register component
  component grx
    port (grxAddr : in unsigned(3 downto 0);
          grxDataIn : in unsigned(31 downto 0);
          grxDataOut : out unsigned(31 downto 0);
          grxRW : in std_logic; --the read/write bit, in read mode when high else write
          clk : in std_logic);
  end component;

  -- micro Memory component
  component uMem
    port(uAddr : in unsigned(6 downto 0);
         uData : out unsigned(24 downto 0));
  end component;

  -- program Memory component
  component pMem
    port(pAddr : in unsigned(31 downto 0);
         pDataOut : out unsigned(31 downto 0);
         pDataIn : in unsigned(31 downto 0);
         readWrite : in std_logic
         );
  end component;

    -- Ultra module component
  component ultra
    port(clk : in std_logic;
	 JA: out unsigned(1 downto 0); -- vcc, trigger, gnd
	 JB: in unsigned(1 downto 0); -- echo
	 Xpixel : buffer unsigned(9 downto 0);
         us_time : buffer unsigned(15 downto 0);
         rst : in std_logic
    );
  end component;

  -- ALU component
  component alu
    port(clk : in std_logic;
         alu_data : in unsigned(31 downto 0);
         alu_opcode : in unsigned (3 downto 0);
         ar : buffer unsigned ( 31 downto 0);
         status : out unsigned (7 downto 0)
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

  component leddriver
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  UNSIGNED(7 downto 0);
           an : out  UNSIGNED (3 downto 0);
           value : in  UNSIGNED (15 downto 0)
           );
  end component;
  
  -- VGA motor component
  component VGA_MOTOR is
  port ( clk			: in std_logic;
	 data			: in std_logic_vector(7 downto 0);
	 addr			: buffer unsigned(10 downto 0);
	 rst			: in std_logic;
	 vgaRed		        : out std_logic_vector(2 downto 0);
	 vgaGreen	        : out std_logic_vector(2 downto 0);
	 vgaBlue		: out std_logic_vector(2 downto 1);
	 Hsync		        : out std_logic;
	 Vsync		        : out std_logic;
         -- first bit 1 if collision, 3-bit enumerated normal.
         collision_one          : buffer unsigned(3 downto 0);
         collision_two          : buffer unsigned(3 downto 0);
         collision_addr_one     : buffer unsigned(10 downto 0);
         collision_addr_two     : buffer unsigned(10 downto 0);
         -- The balls start_stop X and start_stop Y.
         ball_one_posX          : in unsigned(9 downto 0);
         ball_one_posY          : in unsigned(9 downto 0);
         ball_two_posX          : in unsigned(9 downto 0);
         ball_two_posY          : in unsigned(9 downto 0);
         paddle_one_pos : in unsigned(9 downto 0);
         paddle_two_pos : in unsigned(9 downto 0);
         collision_reset        : in std_logic
         
         );
  end component;

  --instruction decoder signal
  signal uMode : unsigned(6 downto 0);
  signal uProg : unsigned(6 downto 0);
  signal uOperand : unsigned(31 downto 0);
  signal grA : unsigned(3 downto 0);
  signal grB : unsigned(3 downto 0);

  --general register
  signal grxDataIn : unsigned(31 downto 0);
  signal grxDataOut : unsigned(31 downto 0);
  signal grxAddr : unsigned (3 downto 0);
  signal grxRW : std_logic;

  -- micro memory signals
  signal uM : unsigned(24 downto 0); -- micro Memory output
  signal uPC : unsigned(6 downto 0); -- micro Program Counter
  signal uPCsig : unsigned(2 downto 0); -- (0:uPC++, 1:uPC=uAddr)
  signal uAddr : unsigned(6 downto 0); -- micro Address
  signal TB : unsigned(3 downto 0); -- To Bus field
  signal FB : unsigned(3 downto 0); -- From Bus field
  signal S : std_logic;
  
  -- ALU signals
  signal ALU_op : unsigned(3 downto 0);   -- ALU opcode
  signal ALUd : unsigned( 31 downto 0);
  signal AR : unsigned(31 downto 0);      -- Accumulator register
  signal SR : unsigned(7 downto 0);       -- Status register
  
  -- program memory signals
  signal PM : unsigned(31 downto 0); -- Program Memory output
  signal PMin : unsigned(31 downto 0);  -- Program Memory input
  signal PMrw : std_logic;              -- read write bit to PM
  signal PC : unsigned(31 downto 0); -- Program Counter
  signal Pcsig : std_logic; -- 0:PC=PC, 1:PC++
  signal ASR : unsigned(31 downto 0); -- Address Register
  signal IR : unsigned(31 downto 0); -- Instruction Register
  signal DATA_BUS : unsigned(31 downto 0); -- Data Bus

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
  signal collision_one_s          : unsigned(3 downto 0);
  signal collision_two_s          : unsigned(3 downto 0);
  signal collision_addr_one_s     : unsigned(10 downto 0);
  signal collision_addr_two_s     : unsigned(10 downto 0);
         -- The balls start_stop X and start_stop Y.
  signal ball_one_posX_s          : unsigned(9 downto 0);
  signal ball_one_posY_s          : unsigned(9 downto 0);
  signal ball_two_posX_s          : unsigned(9 downto 0);
  signal ball_two_posY_s          : unsigned(9 downto 0);
  signal collision_reset_s        : std_logic;
  signal paddle_one_pos_s         : unsigned(9 downto 0);
  signal paddle_two_pos_s         : unsigned(9 downto 0);

begin

  rst <= btns;
  
  -- IR : Instruction Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');
      elsif (FB = "0001") then
        IR <= DATA_BUS;
      end if;
    end if;
  end process;

  -- program memory in
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        PMin <= (others => '0');
        PMrw <= '1';
      elsif (FB = "0010") then
        PMin <= DATA_BUS;
        PMrw <= '0';
      else
        PMrw <= '1';
      end if;
    end if; 
  end process;
  
  -- PC : Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        PC <= (others => '0');
      elsif (FB = "0011") then
        PC <= DATA_BUS;
      elsif (PCsig = '1') then
        PC <= PC + 1;
      end if;
    end if;
  end process;
  
  -- ASR : Address Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');
      elsif (FB = "0100") then
        ASR <= DATA_BUS;
      end if;
    end if;
  end process;
  
  -- general registers
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        grxDataIn <= (others => '0');
      elsif (FB = "0101") then
        grxDataIn <= DATA_BUS;
        grxRW <= '0';
      else
        grxRW <= '1';
      end if;
    end if;
  end process;

  ALUd <= DATA_BUS when (FB="1000") else
          (others => '0');
  
  -- mPC : micro Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        uPC <= (others => '0');
      elsif (uPCsig = "001") then
        uPC <= uAddr;
      elsif (uPCsig = "010") then
        uPC <= uProg;
      elsif (uPCsig = "011") then
        uPc <= uMode;
      elsif (uPCsig = "100") then       --Branch zero
        if (SR(1)='1') then
          uPC <= uAddr;
        else
          uPC <= uPC+1;
        end if;
      elsif uPCsig = "101" then         --Branch minus
        if (SR(0) = '1') then
          uPC <= uAddr;
        else
          uPC <= uPC+1;
        end if;
      else
        uPC <= uPC + 1;
      end if;
    end if;
  end process;
	
  --instruction decoder connection
  ID : instrDec port map (instruction =>IR, operand=>uOperand, uMode=>uMode, uProg=>uProg, grA=>grA, grB=>grB);
  -- general register connection
  GR : grx port map(grxAddr, grxDataIn, grxDataOut, grxRW, clk);

  -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- program memory component connection
  U1 : pMem port map(pAddr=>ASR, pDataOut=>PM, pDataIn=>PMin, readWrite=>PMrw);

   UL : ultra port map(clk=>clk, JA=>JA, JB=>JB, Xpixel=>paddle_one_pos_s, rst=>rst, us_time=>us_time);
  
   -- picture memory component connection
   U3 : PICT_MEM port map(clk=>clk, we1=>we_s, data_in1=>data_s, addr1=>addr_s, we2=>'0', data_in2=>"00000000", data_out2=>data_out2_s, addr2=>addr2_s);

  -- VGA motor component connection
  U4 : VGA_MOTOR port map(clk=>clk, rst=>rst, data=>data_out2_s, addr=>addr2_s, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync, collision_one(3 downto 0)=>collision_one_s(3 downto 0), collision_two=>collision_two_s, ball_one_posX=>ball_one_posX_s, ball_one_posY=>ball_one_posY_s, ball_two_posX=>ball_two_posX_s, ball_two_posY=>ball_two_posY_s, collision_reset=>collision_reset_s, paddle_one_pos=>paddle_one_pos_s, paddle_two_pos=>paddle_two_pos_s, collision_addr_one=>collision_addr_one_s, collision_addr_two=>collision_addr_two_s);

  -- keyboard encoder component connection
 U5 : KBD_ENC port map(clk=>clk, rst=>rst, PS2KeyboardCLK=>PS2KeyboardCLK, PS2KeyboardData=>PS2KeyboardData, data=>data_s, addr=>addr_s, we=>we_s);
  
  AL : alu port map(clk, alu_data=>ALUd, alu_opcode=>ALU_op, ar=>AR, status=>SR);
  
  -- micro memory signal assignment
  uAddr <= uM(6 downto 0);
  uPCsig <= uM(9 downto 7);
  PCsig <= uM(12);
  FB <= uM(16 downto 13);               --Kanse behöver flytta så denna avkänn                             --direkt
  TB <= uM(20 downto 17);
  grxAddr <=
    b"1111" when (uM(11) = '1') else
    grA when (uM(10)= '0') else
    grB when (uM(10) = '1') else
    (others => '0');
  ALU_op <= uM(24 downto 21);

  -- data bus assignment
  DB : DATA_BUS <= IR when (TB = "0001") else
                   PM when (TB = "0010") else
                   PC when (TB = "0011") else
                   ASR when (TB = "0100") else
                   grxDataOut when (TB = "0101") else
                   AR when (TB = "0111") else
                   uOperand when (TB = "1001") else
                   (others => '0');

end Behavioral;
