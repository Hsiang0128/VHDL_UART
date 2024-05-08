library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity receiver is
	generic(
		DBIT 		: integer := 8 ; 	-- # data bits
		SB_TICK	: integer := 16 	-- #tick for stop bits
	) ;
	port(
		clk 				: in std_logic;
		reset				: in std_logic;
		rx 				: in std_logic;
		s_tick 			: in std_logic;
		rx_done_tick	: out std_logic;
		dout 				: out std_logic_vector( 7 downto 0 )
	);
end receiver;
architecture behavior of receiver is
	type state_type is (
		IDLE,
		START,
		DATA,
		STOP
	);
	signal state_reg	: state_type;
	signal counter 	: integer range 0 to (DBIT-1);
	signal data_buf	: std_logic_vector(7 downto 0);
	signal tick_posedge	: std_logic;
	signal tick_tmp		: std_logic;
begin

	tick_posedge <= (s_tick and (not tick_tmp));
	dout <= data_buf;
	process(clk,reset)begin
		if(reset = '1')then
			state_reg 	<= IDLE;
			rx_done_tick <= '0';
			data_buf <= (others => '0');
		elsif(clk'event and clk = '1')then
			tick_tmp <= s_tick;
			case state_reg is
				when IDLE =>
					rx_done_tick <= '0';
					counter 	<= 0;
					if(tick_posedge = '1' and rx = '0')then
						state_reg 	<= START;
					end if;
				when START =>
					if(tick_posedge = '1')then
						data_buf <= rx & data_buf(7 downto 1);
						state_reg 	<= DATA;
					end if;
				when DATA =>
					if(tick_posedge = '1')then
						counter	<= counter +1;
						if(counter = (DBIT - 1))then
							counter <= 0;
							state_reg 	<= STOP;
							if(rx = '1')then
								rx_done_tick <= '1';
							end if;
						else 
							data_buf <= rx & data_buf(7 downto 1);
						end if;
					end if;
				when STOP =>
					rx_done_tick <= '0';
					if(tick_posedge = '1')then
						if(rx = '0')then
							state_reg <= START;
						else
							state_reg <= IDLE;
						end if;
					end if;
			end case;
		end if;
	end process;
--	
--	dout <= b_reg;
--	
--	process(clk,reset) begin
--		if(reset = '1')then
--			state_reg <= IDLE ;
--			n_reg <= (others => '0');
--			b_reg <= (others => '0');
--		elsif(clk'event and clk = '1')then
--			tick_tmp <= s_tick;
--			tick_posedge <= (s_tick and (not tick_tmp));
--			
--			state_reg <= state_next ;
--			n_reg <= n_next ;
--			b_reg <= b_next ;
--		end if ;
--	end process;
--	
--	process(state_reg,n_reg,b_reg,s_tick,rx,tick_posedge)begin
--		state_next <= state_reg;
--		n_next <= n_reg;
--		b_next <= b_reg;
--		rx_done_tick <= '0';
--		case state_reg is
--			when IDLE =>
--				n_next <= (others => '0');
--				if(rx = '0')then
--					state_next 	<= START;
--				end if;
--			when START =>
--				if(tick_posedge = '1')then
--					state_next	<= DATA;
--				elsif(rx = '1')then
--					state_next	<= IDLE;
--				end if;
--			when DATA =>
--				if(tick_posedge = '1')then
--					b_next <= rx & b_reg(7 downto 1);
--					if(n_reg = (DBIT-1))then
--						n_next <= (others => '0');
--						state_next <= STOP;
--					else 
--						n_next <= n_reg + 1;
--					end if;
--				end if;
--			when STOP =>
--				if(tick_posedge = '1') then
--					state_next <= IDLE;
--					if(rx = '1') then
--						rx_done_tick <= '1';
--					end if;
--				end if;
--		end case ;
--	end process;
end behavior;
