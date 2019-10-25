library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

ENTITY rams_01 IS
	PORT (
		clk : in std_logic;
		we : in std_logic;
		en : in std_logic;
		addr : in std_logic_vector(5 downto 0);
		di : in std_logic_vector(15 downto 0);
		do : out std_logic_vector(15 downto 0)
	);
END rams_01;

ARCHITECTURE syn OF rams_01 IS
	TYPE ram_type IS array (63 downto 0) OF std_logic_vector (15 downto 0);
	SIGNAL RAM: ram_type; 
BEGIN
	PROCESS (clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF en = '1' THEN
				IF we = '1' THEN
					RAM(conv_integer(addr)) <= di;
				END IF;
				do <= RAM(conv_integer(addr)) ;
			END IF;
		END IF;
	END PROCESS;
END SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

package memory is
    component rams_01
      port (
        clk : in std_logic;
			we : in std_logic;
			en : in std_logic;
			addr : in std_logic_vector(5 downto 0);
			di : in std_logic_vector(15 downto 0);
			do : out std_logic_vector(15 downto 0)
      );
    end component;
end package;