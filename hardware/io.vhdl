library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

use std.textio.all;

entity fileio is
    port (
    clk : IN STD_LOGIC := '0';
    dpm : OUT positive := 60;
    letter : out character := '0';
    number : out character := '0';
    tsig : out STD_LOGIC := '0'
  ) ;
end fileio;

architecture behaviour of fileio is
begin
  process
    variable line_v : line;
    file read_file : text;
    
    variable bpm : character;
    variable pitch : character;
    variable duration : character;
    
    variable good : boolean;
    variable debug : line;
    variable l : line;
  begin

    --wait for 10 ns;

    file_open(read_file, "music.txt", read_mode);

    write(debug, String'("Music: "));
    writeline(output, debug);

    readline(read_file, line_v);

    read(line_v, bpm, good);
    if good = false then
        write(debug, String'("BAD READ 0."));
        writeline(output, debug);
    end if ;
        
    write(debug, CHARACTER'POS(bpm));
    writeline(output, debug);

    dpm <= CHARACTER'POS(bpm);

    while line_v'length > 1 loop
        wait until rising_edge(clk);
        
        read(line_v, pitch, good);
        if good = false then
            write(debug, String'("BAD READ 1."));
            writeline(output, debug);
        end if ;
        
        read(line_v, duration, good);
        if good = false then
            write(debug, String'("BAD READ 2."));
            writeline(output, debug);
        end if ;
        letter <= pitch;
        number <= duration;
    end loop;

    tsig <= '1';

    wait;
  end process;
end behaviour;


library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
use std.textio.all;

package io is
    component fileio
      port (
        clk : IN STD_LOGIC := '0';
        dpm : OUT positive := 60;
        letter : out character := '0';
        number : out character := '0';
        tsig : out STD_LOGIC := '0'
      ) ;
    end component;
end package;