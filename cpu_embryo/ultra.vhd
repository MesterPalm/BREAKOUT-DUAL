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
    rst : in std_logic);
end ultra;

architecture ultra_behavior of ultra is
  type state is (q_trig, q_wait1, q_echo, q_wait2);
  signal q : state;
  signal us_counter : unsigned (6 downto 0);
  signal us : unsigned (15 downto 0);
  signal us_rst : std_logic;
  signal trig_counter : unsigned (3 downto 0);
  signal trigger :STD_LOGIC;    
  signal echo : STD_LOGIC;
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

                 
end ultra_behavior;
