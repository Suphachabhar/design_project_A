library ieee ;
    use ieee.numeric_std.all ;
	 use IEEE.math_real.all;

entity frequency is
  generic (
		clock_speed : natural
  );
  port (
    char : IN natural range 0 to 127 := character'pos('z');
    count : OUT natural range 0 to natural(ROUND(real(clock_speed)/261.6)) := 0
  ) ;
end frequency ; 

architecture arch of frequency is  
	constant C4 : real := 261.6;
	--constant C4Hz : real := clock_speed/C4;
	constant asciiBase : natural := character'pos('a');
	
	type f_array is array (0 to character'pos('y') - asciiBase) of natural range 0 to natural(ROUND(real(clock_speed)/C4));
	
	signal f_table : f_array;
	
begin

	f_gen: for f in 0 to character'pos('y') - asciiBase generate
		f_table(f) <= natural(ROUND(real(clock_speed)/(C4 * (2.0**(real(f)/12.0)))));
	end generate f_gen;
	
	count <= f_table(char - asciiBase) when char >= character'pos('a') and char <= character'pos('y') else 0;
end architecture arch;

entity duration is
  port (
    num : IN natural range 0 to 127 := character'pos('1');
    comp : OUT natural range 0 to 15 := 0
  ) ;
end duration ; 

architecture arch of duration is  
  begin
    with num select
    comp <=  0 when character'pos('1'),
            1 when character'pos('2'),
            3 when character'pos('3'),
            7 when character'pos('4'),
            11 when character'pos('5'),
            15 when character'pos('6'),
            0 when others;
end architecture ;

library ieee ;
    use ieee.numeric_std.all ;
	 use IEEE.math_real.all;

package maps is
    component frequency
	 generic (
		clock_speed : natural
	  );
	  
      port (
        char : IN natural range 0 to 127 := character'pos('z');
        count : OUT natural range 0 to natural(ROUND(real(clock_speed)/261.6)) := 0
      );
    end component;
    component duration
      port (
        num : IN natural range 0 to 127 := character'pos('1');
        comp : OUT natural range 0 to 15 := 1
      );
    end component;
end package;
