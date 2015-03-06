----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:11:08 02/25/2015 
-- Design Name: 
-- Module Name:    fsm - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm is
	port(	j7_btn_i:		IN STD_LOGIC_VECTOR(1 downto 0);
			led_o: 			OUT STD_LOGIC_VECTOR(6 downto 0));
end fsm;

architecture Behavioral of fsm is
	type state is (a,b,c,d,e,f,g);
	signal pr_state, nxt_state: state;

begin
	process (j7_btn_i(0), j7_btn_i(1))
	begin
		if (j7_btn_i(0)='1') then
			pr_state <= a;
		elsif (j7_btn_i(1)='1') then
			pr_state <= nxt_state;
		end if;
	end process;
	
	process (pr_state, j7_btn_i(1))
	begin
		case pr_state is
			when a =>
				led_o <= "1000000";
				nxt_state <= b;
			when b =>
				led_o <= "0100000";
				nxt_state <= c;
			when c =>
				led_o <= "0010000";
				nxt_state <= d;
			when d =>
				led_o <= "0001000";
				nxt_state <= e;
			when e =>
				led_o <= "0000100";
				nxt_state <= f;
			when f =>
				led_o <= "0000010";
				nxt_state <= g;
			when g =>
				led_o <= "0000001";
				nxt_state <= a;
			when others =>
				led_o <= "0000000";
				nxt_state <= a;
		end case;
		
	end process;
	
end Behavioral;

