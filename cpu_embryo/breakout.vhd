library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--CPU interface
entity breakout is
  port(clk: in std_logic;
       rst: in std_logic;             --rst
       JA: out unsigned(1 downto 0); -- trigger
       JB: in unsigned(1 downto 0); -- echo
       Led : out unsigned(1 downto 0)
       );
end breakout;

architecture Behavioral of breakout is
  --instruction decoder component
  component instrDec
    port (
      instruction : in unsigned(31 downto 0);
      operand : out unsigned(31 downto 0);
      uAddr : out unsigned(6 downto 0);
      grA : out unsigned(3 downto 0);
      grB : out unsigned(3 downto 0);
      clk : std_logic);
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
         uData : out unsigned(22 downto 0));
  end component;

  -- program Memory component
  component pMem
    port(pAddr : in unsigned(31 downto 0);
         pData : out unsigned(31 downto 0));
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

  -- Ultra module component
  component ultra
    port(clk : in std_logic;
	 JA: out unsigned(1 downto 0); -- vcc, trigger, gnd
	 JB: in unsigned(1 downto 0); -- echo
	 us_time : buffer unsigned(31 downto 0);
         rst : in std_logic
    );
  end component;
  --instruction decoder signal
  signal uProg : unsigned(6 downto 0);
  signal operand : unsigned(31 downto 0);
  signal grA : unsigned(3 downto 0);
  signal grB : unsigned(3 downto 0);
  --general register
  signal grxDataIn : unsigned(31 downto 0);
  signal grxDataOut : unsigned(31 downto 0);
  signal grxAddr : unsigned (3 downto 0);
  signal grxRW : std_logic;

  -- micro memory signals
  signal uM : unsigned(22 downto 0); -- micro Memory output
  signal uPC : unsigned(6 downto 0); -- micro Program Counter
  signal uPCsig : unsigned(2 downto 0); -- (0:uPC++, 1:uPC=uAddr)
  signal uAddr : unsigned(6 downto 0); -- micro Address
  signal TB : unsigned(3 downto 0); -- To Bus field
  signal FB : unsigned(3 downto 0); -- From Bus field

  -- ALU signals
  signal ALU_op : unsigned(3 downto 0);   -- ALU opcode
  signal ALUd : unsigned( 31 downto 0);
  signal AR : unsigned(31 downto 0);      -- Accumulator register
  signal SR : unsigned(7 downto 0);       -- Status register
  
  -- program memory signals
  signal PM : unsigned(31 downto 0); -- Program Memory output
  signal PC : unsigned(31 downto 0); -- Program Counter
  signal Pcsig : std_logic; -- 0:PC=PC, 1:PC++
  signal ASR : unsigned(31 downto 0); -- Address Register
  signal IR : unsigned(31 downto 0); -- Instruction Register
  signal DATA_BUS : unsigned(31 downto 0); -- Data Bus

  -- ultra beahvior signal
  signal us_time : unsigned (31 downto 0);
begin
    
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

  -- AX : Accumulator register
--  process (clk)
--  begin
--    if rising_edge(clk) then
--     if (rst = '1') then
--        AR <= (others => '0');
--      elsif (FB = "0111") then
--        AR <= DATA_BUS;
--      end if;
--    end if;
--  end process;
  
      -- ALU
  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ALUd <= (others =>'0');
      elsif (FB = "1000") then
        ALUd <= DATA_BUS;
      end if;
    end if;
  end process;

  
  -- mPC : micro Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        uPC <= (others => '0');
      elsif (uPCsig = "001") then
        uPC <= uAddr;
      elsif uPCsig = "010" then
        uPC <= uProg;
      else
        uPC <= uPC + 1;
      end if;
    end if;
  end process;
	
  --instruction decoder connection
  ID : instrDec port map (instruction =>IR, operand=>operand, uAddr=>uProg, grA=>grA, grB=>grB, clk=>clk);
  -- general register connection
  GR : grx port map(grxAddr, grxDataIn, grxDataOut, grxRW, clk);

  -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- program memory component connection
  U1 : pMem port map(pAddr=>ASR, pData=>PM);

  UL : ultra port map(clk, JA, JB, us_time, rst);

  AL : alu port map(clk, alu_data=>ALUd, alu_opcode=>ALU_op, ar=>AR, status=>SR);
  
  -- micro memory signal assignments
  uAddr <= uM(6 downto 0);
  uPCsig <= uM(9 downto 7);
  PCsig <= uM(10);
  FB <= uM(14 downto 11);
  TB <= uM(18 downto 15);
  grxAddr <= grA when (TB = "0101") else
             grB when (FB = "0101") else
             (others => '0');
  ALU_op <= uM(22 downto 19);

  -- data bus assignment
  DB : DATA_BUS <= IR when (TB = "0001") else
                   PM when (TB = "0010") else
                   PC when (TB = "0011") else
                   ASR when (TB = "0100") else
                   grxDataOut when (TB = "0101") else
                   us_time when (TB = "0110") else
                   AR when (TB = "0111") else
                   operand when (TB = "1001") else
                   (others => '0');

end Behavioral;
