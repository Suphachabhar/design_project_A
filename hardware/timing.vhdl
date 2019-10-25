library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

library UNISIM;
	use UNISIM.Vcomponents.ALL;

entity clock is
	generic (
		max : natural := 1
   );
	port (
		en : std_logic := '0';
		cycle : natural range 0 to max := 1;
		fast_clock : IN  STD_LOGIC;
		slow_clock : OUT STD_LOGIC := '0'
  ) ;
end clock ; 

architecture arch of clock is  
  signal cycle_count : natural range 0 to max-1 := 0;
  signal slow_clock_signal : std_logic := '0';
  begin
    
	 Clock_Buf: BUFG
      port map (I => slow_clock_signal,
                O => slow_clock);
	 
	 
    adder : process( fast_clock )
    begin
      if rising_edge(fast_clock) then
			if en = '1' then
				cycle_count <= cycle_count + 1;
				if cycle_count = cycle/2  then
					slow_clock_signal <= not(slow_clock_signal);
					cycle_count <= 0;
				end if ;
			end if;
      end if ;
    end process ; -- adder

    --slow_clock <= slow_clock_signal;

end architecture ;

library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

library UNISIM;
	use UNISIM.Vcomponents.ALL;

package timing is
    component clock
      generic (
		max : positive := 1
   );
	port (
		en : std_logic := '0';
		cycle : natural range 0 to max := 1;
      fast_clock : IN  STD_LOGIC;
      slow_clock : OUT STD_LOGIC := '0'
	);
	end component;
end package;


-- 101111101011110000100000000 