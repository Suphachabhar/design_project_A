library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity EPP is
    Port(
        clk     : in std_logic;
        EppDB   : inout std_logic_vector(7 downto 0);
        EppAstb : in std_logic;
        EppDstb : in std_logic;
        EppWR   : in std_logic;
        EppWait : out std_logic;
		  
		  memWrite : out std_logic;
		  memData : out std_logic_vector(7 downto 0);
		  memAddr : out std_logic_vector(7 downto 0);
		  
		  memDone : out std_logic
    );
end EPP;

architecture Behavioral of EPP is
	signal    busEppOut: std_logic_vector(7 downto 0);	-- FPGA to PC data
	signal    busEppIn: std_logic_vector(7 downto 0);		-- PC to FPGA data
	 
	signal addrReg : std_logic_vector(7 downto 0);
	signal dataReg : std_logic_vector(7 downto 0);

	signal peripheralWait: std_logic := '0';

	type step_type is (IDLE, READADDR, READDATA, WRITEADDR, WRITEDATA);
	signal stepCurr : step_type := IDLE;
	signal stepNext : step_type;
	
	signal doneCount : natural range 0 to 255 := 0;
	
begin

    -- Handshake signal to indicate when the peripheral is ready.
    EppWait <= peripheralWait;

    -- Input data is read only when writing.

    EppDB <= busEppOut;

	with stepCurr select busEppIn <=
		EppDB when WRITEADDR | WRITEDATA,
		(others => '0') when others;


    -- Advance the state machine
    process(clk)
    begin
        if rising_edge(clk) then
            stepCurr <= stepNext;
        end if;
    end process;

	memAddr <= addrReg;
	memData <= dataReg;

	memWrite <= '1' when stepCurr = WRITEDATA else '0'; -- Set memory write enable	
	
	process(clk)
	begin
	if rising_edge(clk) then
		if stepCurr = WRITEADDR then
			addrReg <= busEPPIn; -- set memory address.
		elsif stepCurr = WRITEDATA then
			dataReg <= busEPPIn; -- Set memory data.
		end if;
	end if;
	end process;
	
	with stepCurr select busEppOut <= 
		addrReg when READADDR,
		dataReg when READDATA,
		(others => 'Z') when others;
	
	peripheralWait <= '0' when stepCurr = IDLE else '1';

	memDone <= '1' when doneCount = 255 else '0';

	process(clk)
	begin
		if rising_edge(clk) then
			doneCount <= 0;
			if (stepCurr = IDLE) then
				if doneCount < 255 then
					doneCount <= doneCount + 1;
				else
					doneCount <= doneCount;
				end if;
			end if;
		end if;
	end process;

    process(clk)
    begin
        if rising_edge(clk) then
				case stepCurr is 
					when IDLE => 
						if EppDstb = '0' then 
							if EppWr = '0' then
								stepNext <= WRITEDATA; -- PC to FPGA Data
							else
								stepNext <= READDATA; -- FPGA Data to PC
							end if;
						end if;

						if EppAstb = '0' then 
							if EppWr = '0' then
								stepNext <= WRITEADDR; -- PC to FPGA Address
							else
								stepNext <= READADDR; -- FPGA Address to PC
							end if;
						end if;
					when WRITEDATA | READDATA =>
						if EppDstb = '1' then
                        stepNext <= IDLE;
						end if;
					when WRITEADDR | READADDR =>
						if EppAstb = '1' then
                        stepNext <= IDLE;
						end if;
				end case;
        end if;
    end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package ports is
	component EPP
		Port(
        clk     : in std_logic;
        EppDB   : inout std_logic_vector(7 downto 0);
        EppAstb : in std_logic;
        EppDstb : in std_logic;
        EppWR   : in std_logic;
        EppWait : out std_logic;
		  
		  memWrite : out std_logic;
		  memData : out std_logic_vector(7 downto 0);
		  memAddr : out std_logic_vector(7 downto 0);
		  
		  memDone : out std_logic
		);
	 end component;
end package;