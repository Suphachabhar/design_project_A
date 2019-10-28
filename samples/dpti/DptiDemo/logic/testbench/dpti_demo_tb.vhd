--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:31:19 12/29/2015
-- Design Name:   
-- Module Name:   C:/sam_work/testruns/DPTI_tests_for_Nexys_Video/DPTI_Basic_Sync_Performance_Test/testbench.vhd
-- Project Name:  DPTI_Basic_Sync_Performance_Test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dpti_basic_sync_performance_test
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dpti_demo
    PORT(
         prog_clko : IN  std_logic;
         prog_rxen : IN  std_logic;
         prog_txen : IN  std_logic;
         btnrst : IN  std_logic;
         sysclk : in std_logic;
         prog_spien : IN  std_logic;
         prog_rdn : OUT  std_logic;
         prog_wrn : OUT  std_logic;
         prog_oen : OUT  std_logic;
         prog_siwun : OUT  std_logic;
         prog_d : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal prog_clko : std_logic := '0';
   signal sysclk : std_logic := '0';
   signal prog_rxen : std_logic := '1';
   signal prog_txen : std_logic := '0';
   signal btnrst : std_logic := '0';
   signal prog_spien : std_logic := '0';

	--BiDirs
   signal prog_d : std_logic_vector(7 downto 0);

 	--Outputs
   signal prog_rdn : std_logic;
   signal prog_wrn : std_logic;
   signal prog_oen : std_logic;
   signal prog_siwun : std_logic;

   --note only read fifo (Host->FPGA) is simulated, write fifo is treated as infinitely deep
   signal fifoCnt : std_logic_vector(15 downto 0) := (others =>'0');
   signal fifoFillFlag : std_logic := '0';
   

   -- Clock period definitions
   constant prog_clko_period : time := 16.667 ns;
   constant sysclk_period : time := 10.000 ns;
   --constant fifo_max : std_logic_vector(15 downto 0) := x"C8"; --200 
   constant fifo_max : std_logic_vector(15 downto 0) := x"2710"; --10000 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dpti_demo PORT MAP (
          prog_clko => prog_clko,
          prog_rxen => prog_rxen,
          prog_txen => prog_txen,
          btnrst => btnrst,
          sysclk => sysclk,
          prog_spien => prog_spien,
          prog_rdn => prog_rdn,
          prog_wrn => prog_wrn,
          prog_oen => prog_oen,
          prog_siwun => prog_siwun,
          prog_d => prog_d
        );

   -- Clock process definitions
   prog_clko_process :process
   begin
		prog_clko <= '0';
		wait for prog_clko_period/2;
		prog_clko <= '1';
		wait for prog_clko_period/2;
   end process;
   
   sysclk_process :process
   begin
        sysclk <= '0';
        wait for sysclk_period/2;
        sysclk <= '1';
        wait for sysclk_period/2;
   end process;
 
   fifo_cnt_proc : process (prog_clko)
   begin
      if (rising_edge(prog_clko)) then
        if (fifoFillFlag = '1') then
          fifoCnt <= fifo_max;
        else
          if (((prog_rdn = '0' and prog_oen = '0') and prog_rxen = '0') and (fifoCnt /= 0)) then
            fifoCnt <= fifoCnt - 1;
          end if;
        end if;
      end if;
   end process;
  

   data_bus_proc : process (prog_oen, prog_rxen, prog_clko)
   begin
     if (prog_oen = '1' or prog_rxen = '1') then
        prog_d <= (others => 'Z');
     elsif ( rising_edge(prog_clko) ) then
     --This process is emulating the FIFO data at the FTDI part. In order to keep this
     --simple, I just use the current fifo index as the data. In order for this to work
     --correctly, I have to simulate data pre-loading on the output of the FIFO, which requires
     --the if/else check below.
        if (prog_rdn = '0') then
            prog_d <= (others => 'X') after 1 ns, (fifoCnt(7 downto 0)-1) after 7.15 ns;
        else
            prog_d <= (others => 'X') after 1 ns, fifoCnt(7 downto 0) after 7.15 ns;
        end if;
     end if;
  end process;


  prog_rxen_proc : process (prog_clko)
  begin
    if ( rising_edge(prog_clko) ) then
      if (prog_rxen = '1' and  (fifoCnt /= 0)) then
        prog_rxen <= 'X' after 1 ns, '0' after 7.15 ns;
      elsif (prog_rxen = '0' and  (fifoCnt = 0)) then
        prog_rxen <= 'X' after 1 ns, '1' after 7.15 ns;
      end if;      
    end if;
  end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      btnrst <= '1';
      prog_spien <= '1';
      wait for 100 ns;	
      btnrst <= '0';
      prog_spien <= '0';
      
      wait for prog_clko_period*10;
      fifoFillFlag <= '1';  --emulate the host filling the FIFO via a USB transaction
      wait for prog_clko_period;
      fifoFillFlag <= '0';
      
      -- insert stimulus here 

      wait;
   end process;

END;
