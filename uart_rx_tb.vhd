LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY uart_rx_tb IS
END uart_rx_tb;
 
ARCHITECTURE behavior OF uart_rx_tb IS 
	COMPONENT uart_rx
	PORT(
		clk : IN  std_logic;
		reset : IN  std_logic;
		rx : IN  std_logic;
		s_tick : IN  std_logic;
		rx_done_tick : OUT  std_logic;
		dout : OUT  std_logic_vector(7 downto 0)
	  );
	END COMPONENT;
	
   signal clk : std_logic := '0';
   signal reset : std_logic := '1';
   signal rx : std_logic := '1';
   signal s_tick : std_logic := '0';
   signal rx_done_tick : std_logic;
   signal dout : std_logic_vector(7 downto 0);
	
	constant testData			: std_logic_vector(7 downto 0) := "11001001"; -- my test data
   constant clk_period 		: time := 2 ns;
	constant s_tick_period 	: time := 64 ns;
 
BEGIN

   uut: uart_rx PORT MAP (
          clk => clk,
          reset => reset,
          rx => rx,
          s_tick => s_tick,
          rx_done_tick => rx_done_tick,
          dout => dout
        );

   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	s_tick_process :process
   begin
		s_tick <= '0';
		wait for s_tick_period/2;
		s_tick <= '1';
		wait for s_tick_period/2;
   end process;
	
   stim_proc: process
   begin	
		wait for 10ns;
		reset <= '0';
		wait for 10ns;
		----<Start>-----------------------------
		rx <= '0'; 
		wait for s_tick_period;
		----<Send Data>-------------------------
		for i in 0 to 7 loop
			rx <= testData(i);
			wait for s_tick_period;
		end loop;
		----<End>-----------------------------
		rx <= '1';
		wait for 64ns;
      wait;
   end process;
END;
