library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ultra is
  Port (
    clk : in STD_LOGIC;
    JA : out unsigned(1 downto 0);
    JB : in unsigned(1 downto 0);
    --vcc : out STD_LOGIC;
    --trigger : out STD_LOGIC;    
    --echo : in STD_LOGIC;
    --gnd : out STD_LOGIC;
    us_time : buffer unsigned (15 downto 0);
    Xpixel  : buffer unsigned (9 downto 0);
    rst : in std_logic);
end ultra;

architecture ultra_behavior of ultra is
  type state is (q_trig, q_wait1, q_echo, q_wait2);
  signal q : state;
  signal us_counter : unsigned (6 downto 0);
  signal us : unsigned (15 downto 0);
  --signal us_time : unsigned (15 downto 0);
  signal us_rst : std_logic;
  signal trig_counter : unsigned (3 downto 0);
  signal trigger :STD_LOGIC;    
  signal echo : STD_LOGIC;
  signal diff : unsigned(11 downto 0);
  signal Xpixel_temp : unsigned(11 downto 0);
  signal avg1 : unsigned(11 downto 0);
  signal avg2 : unsigned(11 downto 0);
  signal avg3 : unsigned(11 downto 0);
  signal avg4 : unsigned(11 downto 0);
  signal avg5 : unsigned(11 downto 0);
  signal avg6 : unsigned(11 downto 0);
  signal avg7 : unsigned(11 downto 0);
  signal avg8 : unsigned(11 downto 0);
  signal avg_sum : unsigned(11 downto 0);
  signal temp_sum : unsigned(11 downto 0);

begin
  JA(0) <= trigger; 
  echo <= JB(0);

  process (clk) begin
    if rising_edge(clk) then
      if (rst = '1') then
        us_counter <= "0000000";
        us <= X"0000";
      else
        if (us_rst = '1') then
          us_counter <= "0000000";
          us <= X"0000";
        else
          if (us_counter = 99) then          
            us <= us + 1;
            us_counter <= "0000000";
          else
            us_counter <= us_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  
  process (clk) begin
    if rising_edge(clk) then
      if (rst = '1') then
        trigger <= '1';
        q <= q_trig;
      else        
        if (q = q_trig) then
          if (us = 10) then
            q <= q_wait1;
            trigger <= '0';
          end if;
        elsif (q = q_wait1) then
          if (echo = '1') then
            q <= q_echo;
          end if;
        elsif (q = q_echo) then
          if (echo = '0') then
            us_time <= us;
            q <= q_wait2;
          end if;
        elsif (q = q_wait2) then
          if (us = 10000) then
            trigger <= '1';
            q <= q_trig;          
          end if;     
        end if;
      end if;
    end if;
  end process;
  
  process (clk) begin
   if rising_edge(clk) then
     if (rst = '1') then
       us_rst <= '0';
     else
       if us_rst = '1' then
         us_rst <= '0';
       elsif (q = q_wait1 and echo = '1')
         or (q = q_echo and echo = '0')
         or (q = q_wait2 and us = 10000) then
         us_rst <= '1';
       end if;
     end if;
   end if;
  end process;

  process (clk) begin
    if rising_edge(clk) then
      if (rst = '1') then
        avg_sum <= "000011100000"; --Xpixel_temp;
        avg1 <= "000011100000";
        avg2 <= "000011100000";
        avg3 <= "000011100000";
        avg4 <= "000011100000";

      else
        if diff < 65 then
          avg1 <= avg2;
          avg2 <= avg3;
          avg3 <= avg4;
          avg4 <= avg5;
          avg5 <= avg6;
          avg6 <= avg7;
          avg7 <= avg8;         
          avg8 <= Xpixel_temp;
          avg_sum <= avg1 + avg2 + avg3 + avg4 + avg5 + avg6 + avg7 + avg8;
        end if;
        Xpixel <= ("0" & avg_sum(11 downto 3)) + 40;
        
      end if;
    end if;
  end process;
  
  temp_sum <= "000" & avg_sum(11 downto 3); 
  diff <= temp_sum - Xpixel_temp when temp_sum > Xpixel_temp else Xpixel_temp - temp_sum;
  Xpixel_temp <= ("000" & us_time(10 downto 2));
  
end ultra_behavior;
