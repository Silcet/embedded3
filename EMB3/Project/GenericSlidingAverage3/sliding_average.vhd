----------------------------------------------------------------------------------
-- Company: University Of Southern Denmark
-- Engineer: Anders Blaabjerg Lange
-- 
-- Create Date:    11:10:00 06/02/2012 
-- Design Name: 
-- Module Name:    sliding-average - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sliding_average is
	generic(
		G_COLOR_WIDTH  : integer := 10;
		G_PXL_CLK_PRD	: time := 39721946 fs
	);

	port (	
		clk_i 		: in	std_logic;	-- On board clock
		reset_i		: in	std_logic;
		adc_i_R		: in	std_logic_vector(G_COLOR_WIDTH-1 downto 0);
		adc_i_G		: in	std_logic_vector(G_COLOR_WIDTH-1 downto 0);
		adc_i_B		: in	std_logic_vector(G_COLOR_WIDTH-1 downto 0);
		
		--dac_o			: out	std_logic_vector(9 downto 0);	***Now the outputs are r_o, g_o and b_o
		adc_clk_o_R	: out	std_logic;
		adc_clk_o_G	: out	std_logic;
		adc_clk_o_B	: out	std_logic;

		r_o  			: out std_logic_vector (G_COLOR_WIDTH-1 downto 0);
		g_o  			: out std_logic_vector (G_COLOR_WIDTH-1 downto 0);
		b_o  			: out std_logic_vector (G_COLOR_WIDTH-1 downto 0);
		hs_o 			: out std_logic;
		vs_o 			: out std_logic
	);
end sliding_average;


architecture Behavioral of sliding_average is

	----------------------------------------------------------------
	-- AVERAGE FILTER DECLARATIONS
	----------------------------------------------------------------
	
	-- constant declarations
	constant C_DATA_CNT 	: integer := 12;
		
	-- type declarations
	type slav_array_type is array(integer range <>) of unsigned(9 downto 0);
	
	-- signal declarations
	signal slav_delay_R				: slav_array_type(0 to C_DATA_CNT-1) := (others=>(others=>'0'));
	signal slav_delay_G				: slav_array_type(0 to C_DATA_CNT-1) := (others=>(others=>'0'));
	signal slav_delay_B				: slav_array_type(0 to C_DATA_CNT-1) := (others=>(others=>'0'));
	signal sum_sig_R 					: unsigned(13 downto 0 );
	signal sum_sig_G 					: unsigned(13 downto 0 );
	signal sum_sig_B 					: unsigned(13 downto 0 );
	
	signal division_dividend		: unsigned(13 downto 0);
	signal division_quotient		: unsigned(13 downto 0);
	signal division_quotient_slv	: std_logic_vector(13 downto 0);
	
	-- component declarations
	component divider
		port (
		clk: in std_logic;
		rfd: out std_logic;
		dividend: in std_logic_vector(13 downto 0);
		divisor: in std_logic_vector(3 downto 0);
		quotient: out std_logic_vector(13 downto 0);
		fractional: out std_logic_vector(3 downto 0));
	end component;
		
	----------------------------------------------------------------
	-- VGA GENERATOR DECLARATIONS
	----------------------------------------------------------------
	
	-- If we count pixels from the falling edge of the HS then there is 144 blank pixels before the first visible pixel
		
	signal C_H_FP : integer := 16;		--Front porch
	signal C_H_SP : integer := 96;		--Synchronization pulse
	signal C_H_BP : integer := 48;		--Back porch
	signal C_H_PX : integer := 640;
	
	signal C_HS_OFFSET : integer := C_H_SP+C_H_BP;	
	signal C_PIXEL_PR_LINE : integer := C_H_FP+C_H_SP+C_H_BP+C_H_PX;	--Num of pixels in a line + lenght of the first porchs
	

	-- If we count lines from the falling edge of the VS then there is 35 blank lines before the first visible line.
	
	signal C_V_FP : integer := 10;
	signal C_V_SP : integer := 2;
	signal C_V_BP : integer := 33;
	signal C_V_LN : integer := 480;
	
	signal C_VS_OFFSET : integer := C_V_SP+C_V_BP;	
	signal C_LINES_PR_FRAME : integer := C_V_FP+C_V_SP+C_V_BP+C_V_LN;	 --Num of lines in a frame + lenght of the first porchs
	
	-- VGA clock for pixels
	signal pxl_clk			: std_logic;
	
	-- Counters for HS and VS signals 
	signal pixel_cnt_reg : unsigned(9 downto 0) := (others=>'0');
	signal pixel_cnt_nxt : unsigned(9 downto 0);
	
	signal line_cnt_reg : unsigned(9 downto 0) := (others=>'0');
	signal line_cnt_nxt : unsigned(9 downto 0);
	
	-- Temporal variable for the filtered output of the three channels
	signal filtered_R : std_logic_vector (G_COLOR_WIDTH-1 downto 0);
	signal filtered_G : std_logic_vector (G_COLOR_WIDTH-1 downto 0);
	signal filtered_B : std_logic_vector (G_COLOR_WIDTH-1 downto 0);
	
	
begin

	----------------------------------------------------------------
	-- Divider core for the average filter
	----------------------------------------------------------------	
		divider_inst : divider
		port map (
			clk 			=> clk_i,
			rfd 			=> open,
			dividend 	=> std_logic_vector(division_dividend),
			divisor 		=> std_logic_vector(to_unsigned(C_DATA_CNT,4)),
			quotient 	=> division_quotient_slv,
			fractional 	=> open
			);		
			
		division_quotient <= unsigned(division_quotient_slv);
	----------------------------------------------------------------
	
	----------------------------------------------------------------
	-- SLIDING AVERAGE FILTER MODULE
	----------------------------------------------------------------	

	-- Clock outputs for the ADCs
		adc_clk_o_R <= clk_i;
		adc_clk_o_G <= clk_i;
		adc_clk_o_B <= clk_i;

	
	-- Sliding Average logic
		process(clk_i)
			variable sum_R	: unsigned(13 downto 0) := (others => '0');
			variable sum_G	: unsigned(13 downto 0) := (others => '0');
			variable sum_B	: unsigned(13 downto 0) := (others => '0');
			variable sum	: unsigned(13 downto 0) := (others => '0');
		
		begin
			if rising_edge(clk_i) then
				if(reset_i = '1') then
					sum_sig_R <= (others => '0');
					sum_sig_G <= (others => '0');
					sum_sig_B <= (others => '0');
				else
					slav_delay_R(0) <= unsigned(adc_i_R);
					slav_delay_G(0) <= unsigned(adc_i_G);
					slav_delay_B(0) <= unsigned(adc_i_B);
					--sum := resize(slav_delay(0), 14);
					
					for i in 1 to C_DATA_CNT-1 loop				
						slav_delay_R(i) <= slav_delay_R(i-1);
						slav_delay_G(i) <= slav_delay_G(i-1);
						slav_delay_B(i) <= slav_delay_B(i-1);
					end loop;
					
					sum_R:=resize(slav_delay_R(11),14)-resize(slav_delay_R(0),14)-sum_sig_R;
					sum_G:=resize(slav_delay_G(11),14)-resize(slav_delay_G(0),14)-sum_sig_G;
					sum_B:=resize(slav_delay_B(11),14)-resize(slav_delay_B(0),14)-sum_sig_B;
					
					sum_sig_R <= sum_R;
					sum_sig_G <= sum_G;					
					sum_sig_B <= sum_B;
					
					-- *************** Change division_quoatient
					filtered_R <= std_logic_vector(resize(division_quotient, 10));
					filtered_G <= std_logic_vector(resize(division_quotient, 10));
					filtered_B <= std_logic_vector(resize(division_quotient, 10));
					
				end if;
			end if;
		end process;
		
		-- *************************** Create three different dividers and their signals
		division_dividend <= unsigned(sum_sig_R);
		division_dividend <= unsigned(sum_sig_G);
		division_dividend <= unsigned(sum_sig_B);


	----------------------------------------------------------------
	-- VGA GENERATOR MODULE
	----------------------------------------------------------------
	
	-- pixel clock generator	****** Generate it scaling down the CLK??
	process
	begin
		pxl_clk <= '0';
		wait for G_PXL_CLK_PRD/2;
		pxl_clk <= '1';
		wait for G_PXL_CLK_PRD/2;
	end process;
	
	-- HS and VS generator
	process(pxl_clk)
	begin
		if rising_edge(pxl_clk) then		
			pixel_cnt_reg <= pixel_cnt_nxt;
			line_cnt_reg <= line_cnt_nxt;
		end if;
	end process;
	
	-- Pixels counter
	pixel_cnt_nxt <= pixel_cnt_reg+1 when pixel_cnt_reg<C_PIXEL_PR_LINE-1 else (others=>'0');
	-- Lines counter
	line_cnt_nxt <= line_cnt_reg+1 when pixel_cnt_reg=C_PIXEL_PR_LINE-1 and line_cnt_reg<C_LINES_PR_FRAME-1 else 
						 (others=>'0')  when pixel_cnt_reg=C_PIXEL_PR_LINE-1 else
						 line_cnt_reg;
	
	-- Synchronization signals
	hs_o <= '0' when pixel_cnt_reg < C_H_SP else '1';		-- Pulse before a new line starts (all the pixels in the line are sent)
	vs_o <= '0' when line_cnt_reg < C_V_SP else '1'; 		-- Pulse before a new frame starts (all the lines in the frame are sent)
	
	-- OUTPUTS:
	-- The Front porch+synch period+back porch periods are implemented in each signal (C_HS_OFFSET AND C_VS_OFFSET)
	
	-- left bat output (GREEN)
	g_o <= (filtered_G) when (pixel_cnt_reg  >= (C_HS_OFFSET) and 
										pixel_cnt_reg <= (C_HS_OFFSET) and 
										line_cnt_reg  >= (C_VS_OFFSET) and 
										line_cnt_reg  <= (C_VS_OFFSET)) else
			 (others=>'0');

	-- ball bat output (RED)
	r_o <= (filtered_R) when (pixel_cnt_reg  >= (C_HS_OFFSET) and 
										pixel_cnt_reg <= (C_HS_OFFSET) and 
										line_cnt_reg  >= (C_VS_OFFSET) and 
										line_cnt_reg  <= (C_VS_OFFSET)) else
			 (others=>'0');

	-- right bat output (BLUE)
	b_o <= (filtered_B) when (pixel_cnt_reg  >= (C_HS_OFFSET) and 
										pixel_cnt_reg <= (C_HS_OFFSET) and 
										line_cnt_reg  >= (C_VS_OFFSET) and 
										line_cnt_reg  <= (C_VS_OFFSET)) else
			 (others=>'0');

	
end Behavioral;

