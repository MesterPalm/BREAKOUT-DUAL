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
       an : out unsigned (3 downto 0)
       );
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

  -- ALU component
  component alu
    port(clk : in std_logic;
         alu_data : in unsigned(15 downto 0);
         alu_opcode : in unsigned (3 downto 0);
         ar : buffer unsigned ( 15 downto 0);
         status : out unsigned (7 downto 0)
         );
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

  -- ALU signals
  signal ALU_op : unsigned(3 downto 0);   -- ALU opcode
  signal ALUd : unsigned( 15 downto 0);
  signal AR : unsigned(15 downto 0);      -- Accumulator register
  signal SR : unsigned(7 downto 0);       -- Status register
  
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

  -- AX : Accumulator register
  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        AR <= (others => '0');
      elsif (FB = "010") then
        AR <= DATA_BUS;
      end if;
    end if;
  end process;

    -- ALU
  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ALUd <= (others =>'0');
      elsif (FB = "101") then
        ALUd <= DATA_BUS;
      end if;
    end if;
  end process;

  Led(0) <= '1' when (us_time > 750) else '0';
	
  -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- program memory component connection
  U1 : pMem port map(pAddr=>ASR, pData=>PM);

  UL : ultra port map(clk, JA, JB, us_time, rst);

  AL : alu port map(clk, alu_data=>ALUd, alu_opcode=>ALU_op, ar=>AR, status=>SR);

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

  ALU_op <= IR(15 downto 12);
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
    AR when (TB = "110") else
   (others => '0');

end Behavioral;
