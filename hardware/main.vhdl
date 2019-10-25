library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
	 use ieee.math_real.all;

	 use work.hex.all;
	 use work.clocks.all;
    use work.maps.all;
	 use work.memory.all;
    use work.timing.all;
	 use work.ports.all;

entity main is
Port (
	clk    : in std_logic;
	EppAstb : in std_logic;
	EppDstb : in std_logic;
	EppWr   : in std_logic;
	EppWait : out std_logic;
	EppDB   : inout std_logic_vector(7 downto 0);
	swt     : in std_logic_vector(7 downto 0);
	led     : out std_logic_vector(7 downto 0);--7 downto 0);
	an      : out std_logic_vector(3 downto 0);
	ssg     : out std_logic_vector(7 downto 0);
	music		: out std_logic);
end main;

architecture arch of main is
	constant speed : natural := 25000000;
	constant speed16 : natural := 25000000/16;
	
	constant beatToDemi : real := 1.0/8.0;
	
	constant speed60 : natural := natural(ROUND(real(speed16)*beatToDemi));
	constant speed120 : natural := speed60/2;
	constant speedDelta : natural := speed60 - speed120;
	
	constant min2sec : natural := 60;
	
	constant minTempo : natural := 60;
	constant maxTempo : natural := 120;
		
	constant hq_note : natural := 8;
	constant asciiMax : natural := 127;

	constant maxSpeed : natural := (maxTempo-minTempo)*speedDelta;
	
	constant speedBits : natural := natural(CEIL(log2(real(maxSpeed+1))));

	type write_state is (IDLE, STARTWRITE, NOWRITE, LOWERWRITE, NEXTADDR, UPPERWRITE);
	signal write_fsm : write_state := IDLE;
	signal write_next : write_state;

	subtype clk16Range is natural range speed120 to speed60;

	signal q_beat : std_logic := '0';
   signal tempo : positive range minTempo to maxTempo := minTempo;
	
	signal beat_comparator : natural range 0 to 31 := 7;
	
	signal letter : natural range 0 to asciiMax := character'pos('a');
   signal number : natural range 0 to asciiMax := character'pos('0');

   signal beat : std_logic := '0';
   signal f : std_logic := '0';

   signal f_count : natural range 0 to natural(ROUND(real(speed16)/261.6)) := 1;

   signal clk16Comparator : clk16Range;-- := natural(to_integer(UNSIGNED(interp(speedBits-1 downto 6)))); -- Divide by X2-X1 64 (by shifting instead of divide by minTempo)
	 	 
	signal reset : std_logic := '1';
	 
	signal readAddr : std_logic_vector(5 downto 0) := (OTHERS => '0');
	signal writeAddr : std_logic_vector(7 downto 0) := (OTHERS => '0');
	signal address	: std_logic_vector(5 downto 0) := (OTHERS => '0');
	
	signal dataOut : std_logic_vector(15 downto 0) := (OTHERS => '0');
	signal memData : std_logic_vector(7 downto 0) := (OTHERS => '0'); -- Data received from USB
	
	signal dClk				: std_logic;
	signal clock_lock		: std_logic;
	signal div16_clock	: std_logic;
	
	signal memWrite 	: std_logic;
	signal dataIn		: std_logic_vector(15 downto 0);	-- Data being written to memory.
	signal memWait 	: std_logic; 							-- FPGA is in writing to memory state. Don't accept more USB data until low.
	signal FSMWait		: std_logic;
	signal memdone 	: std_logic; 							-- USB appears to have stopped sending data. Begins reading.
	
	type word_half is (UPPER, LOWER);
	signal mem_byte : word_half := UPPER;
	 
begin

	--led(6 downto 0) <= std_logic_vector(to_unsigned(tempo, 7));--swt;
	--led(5 downto 0) <= address;
	--led(6) <= q_beat;
	--led(7) <= memDone;
	
	process(dclk)
	begin
		if rising_edge(dclk) then
			if SWT(7) = '1' then
				led <= dataOut(15 downto 8);
			elsif SWT(6) = '1' then
				led <= dataOut(7 downto 0);
			elsif SWT(5) = '1' then
				led(7) <= q_beat;
				led(6 downto 0) <= STD_LOGIC_VECTOR(TO_UNSIGNED(tempo, 7));
			elsif SWT(4) = '1' then
				led(7) <= q_beat;
				led(6) <= beat;
				led (5 downto 0) <= address;
			elsif SWT(3) = '1' then
				CASE write_fsm IS
					when IDLE =>
						led <= '1' & "0000000";
					when STARTWRITE =>
						led <= '0' & '1' & "000000";
					when LOWERWRITE =>
						led <= "00" & '1' & "00000";
					when UPPERWRITE =>
						led <= "000" & '1' & "0000";
					when NOWRITE =>
						led <= "0000" & '1' & "000";
					when NEXTADDR =>
						led <= "00000" & '1' & "00";
				end case;
			elsif SWT(2) = '1' then
				led(7) <= memdone;
				led(6) <= memwrite;
				led(5) <= memwait;
			else
				led <= (others => '0');
			end if;
		end if;
	end process;
	
	display: bcd PORT MAP(dClk, number, letter, an, ssg);

	bDcm: baseDCM PORT MAP(clk, '0', div16_clock, dClk, clock_lock);

	music <= f;

	letter <= natural(to_integer(UNSIGNED(dataOut(15 downto 8))));
	number <= natural(to_integer(UNSIGNED(dataOut(7 downto 0))));

	clk16Comparator <= speed120 + (speedDelta/(maxTempo-minTempo)) * (maxTempo - tempo);
	
   Clock2Hq: clock GENERIC MAP (speed60) PORT MAP (clock_lock, clk16Comparator, div16_clock, q_beat);
   Hq2Note: clock GENERIC MAP (31) PORT MAP (clock_lock, beat_comparator, q_beat, beat);

	process(beat)
	begin
		if rising_edge(beat) then
			if (memDone = '1') then
				reset <= '0';
				readAddr <= STD_LOGIC_VECTOR(UNSIGNED(readAddr) + 1);
				if reset = '1' then
					tempo <= positive(number);
				end if;
				if letter = character'pos('@') then
					reset <= '1';
					readAddr <= (OTHERS => '0');
				end if;
			else
				reset <= '1';
				readAddr <= (OTHERS => '0');
			end if;
		end if;
	end process;

	freqMap: frequency GENERIC MAP (speed/16) PORT MAP (letter, f_count);
	beatMap: duration PORT MAP (number, beat_comparator);

	f_counter: clock GENERIC MAP (natural(real(speed16)/261.6)) PORT MAP (clock_lock, f_count, div16_clock, f);

	process(dclk)
	begin 
		if rising_edge(dclk) then
			address <= address; -- Maintain state.
			case write_fsm is
				when IDLE =>
					address <= readAddr;
				when STARTWRITE =>
					address <= writeAddr(5 downto 0);
				when LOWERWRITE =>
					dataIn(7 downto 0) <= memData;
					mem_byte <= UPPER;
				when UPPERWRITE =>
					dataIn(15 downto 8) <= memData;
					mem_byte <= LOWER;
				when NEXTADDR =>
					address <= STD_LOGIC_VECTOR(UNSIGNED(address) + 1);
				when NOWRITE =>
					
			end case;
		end if;
	end process;

	process(dclk)
	begin
		if rising_edge(dclk) then
			write_fsm <= write_next;
		end if;
	end process;

	process(dclk, memWrite)
	begin
		if rising_edge(dclk) then
			if memDone = '1' then
				write_next <= IDLE; -- USB detected no transfer for time period. Considered done.
			else
				if FSMWait = '1' then
					case write_fsm is
						when IDLE =>
							write_next <= STARTWRITE;
						when STARTWRITE =>
							if mem_byte = UPPER then
								write_next <= UPPERWRITE;
							else
								write_next <= LOWERWRITE;
							end if;
						when LOWERWRITE =>
							write_next <= NEXTADDR;
						when UPPERWRITE =>
							write_next <= NOWRITE;
						when NEXTADDR =>
							write_next <= NOWRITE;
						when NOWRITE =>
							write_next <= NOWRITE;
					end case;
				else
					case write_fsm is
						when NOWRITE =>
							if mem_byte = UPPER then
								write_next <= UPPERWRITE;
							else
								write_next <= LOWERWRITE;
							end if;
						when others =>
							write_next <= write_next;
					end case;
				end if;
			end if;
		end if;
	end process;
	
	mem: rams_01 PORT MAP (dClk, memWrite, clock_lock, address, dataIn, dataOut);

	EPPWait <= FSMWait;
	FSMWait <= '1' when memWait = '1' OR NOT(write_fsm = NOWRITE OR write_fsm = IDLE) else '0';
	usb: EPP PORT MAP (dclk, EppDB, EppAstb, EppDstb, EppWr, memWait, memWrite, memData, writeAddr, memDone);

end architecture ;