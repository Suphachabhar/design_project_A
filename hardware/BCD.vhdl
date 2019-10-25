library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity BCD is
	port (
		clk : in std_logic;
		num : in natural range 0 to 127 := 0;
		char : in natural range 0 to 127 := 0;
		pos : out std_logic_vector(3 downto 0);
		disp : out std_logic_vector(7 downto 0)
	);
end BCD;

architecture Behavioral of BCD is
	signal number : std_logic_vector(7 downto 0);
	signal letterB : std_logic_vector(7 downto 0);
	signal letterA : std_logic_vector(7 downto 0);
	signal count : natural range 0 to 25000000/16/60/4;
	signal refrate : natural range 0 to 3 := 0;
begin

with num select
number <= "00111111" when character'pos('0'),
			"00000110" when character'pos('1'),
			"01011011" when character'pos('2'),
			"01001111" when character'pos('3'),
			"01100110" when character'pos('4'),
			"01101101" when character'pos('5'),
			"01111101" when character'pos('6'),
			"00000111" when character'pos('7'),
			"01111111" when character'pos('8'),
			"01101111" when character'pos('9'),
			"10000000" when others;
			
with char select		
letterB <= "00111111" when character'pos('a') | character'pos('k') | character'pos('u'),
			"00000110" when character'pos('b') | character'pos('l') | character'pos('v'),
			"01011011" when character'pos('c') | character'pos('m') | character'pos('w'),
			"01001111" when character'pos('d') | character'pos('n') | character'pos('x'),
			"01100110" when character'pos('e') | character'pos('o') | character'pos('y'),
			"01101101" when character'pos('f') | character'pos('p') | character'pos('z'),
			"01111101" when character'pos('g') | character'pos('q'),
			"00000111" when character'pos('h') | character'pos('r'),
			"01111111" when character'pos('i') | character'pos('s'),
			"01101111" when character'pos('j') | character'pos('t'),
			"10000000" when others;

with char select	
letterA <= "00111111" when character'pos('a') | character'pos('b') | character'pos('c') | character'pos('d') | character'pos('e') | character'pos('f') | character'pos('g') | character'pos('h') | character'pos('i') | character'pos('j'),
			"00000110" when character'pos('k') | character'pos('l') | character'pos('m') | character'pos('n') | character'pos('o') | character'pos('p') | character'pos('q') | character'pos('r') | character'pos('s') | character'pos('t'),
			"01011011" when character'pos('u') | character'pos('v') | character'pos('w') | character'pos('x') | character'pos('y') | character'pos('z'),
			"10000000" when others;

display: process(clk)
begin
	if rising_edge(clk) then
		if (count = 25000000/16/60/4) then
			count <= 0;
		else
			count <= count + 1;
		end if;
	end if;
end process;

refresh: process(clk)
begin
	if rising_edge(clk) then
		if (count = 0) then
			refrate <= refrate + 1;
		end if;
	end if;
end process;

with refrate select
pos <= 
	"0001" when 0,
	"0010" when 1,
	"0100" when 2,
	"1000" when others;

with refrate select
disp <= not(number) when 0,
	not(letterA) when 1,
	not(letterB) when 2,
	(OTHERS => '1') when others;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package HEX is
component BCD
	port (
		clk : in std_logic;
		num : in natural range 0 to 127 := 0;
		char : in natural range 0 to 127 := 0;
		pos : out std_logic_vector(3 downto 0);
		disp : out std_logic_vector(7 downto 0)
	);
end component;
end package;