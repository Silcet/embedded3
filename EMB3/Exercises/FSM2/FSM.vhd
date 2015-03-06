library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std;

entity FSM is
    Port ( clk_200M_i  : in   STD_LOGIC;
           j7_btn_i    : in   STD_LOGIC_VECTOR (1 downto 0);
           led_o       : out  STD_LOGIC_VECTOR (6 downto 0));
end FSM;

architecture Behavioral of FSM is
	TYPE state IS (S0, S1, S2, S3, S4, S5, S6);
	SIGNAL curr_state, next_state: state;
	ATTRIBUTE ENUM_ENCODING: STRING;
	ATTRIBUTE ENUM_ENCODING OF state: TYPE IS "sequential";
	
	SIGNAL rst, nxt, clk, clk_20 : STD_LOGIC;
	SIGNAL light : STD_LOGIC_VECTOR (6 downto 0);
	SIGNAL flag :	STD_LOGIC;
	
BEGIN
	rst <= j7_btn_i(0);
	nxt <= j7_btn_i(1);
	clk <= clk_200M_i;

	--------------Lower section FSM-------------------
	
	PROCESS (clk_20)
		VARIABLE	clk_scale: INTEGER RANGE   0 to 7000000 := 0;
	BEGIN
		IF(clk'event AND clk='1') THEN
			clk_scale:=clk_scale+1;
			IF (clk_scale=7000000) THEN
				clk_scale:=0;
				clk_20<=NOT clk_20;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (clk_20, rst)
	BEGIN
		IF (rst='0') THEN
			flag <= '0';
		ELSIF (clk_20'EVENT AND clk_20='1') THEN
			IF (nxt='1') THEN
				flag <= '1';
			ELSE
				flag <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (clk_20, rst)
	BEGIN
		IF (rst='0') THEN
			curr_state <= S0;
		ELSIF (clk_20'EVENT AND clk_20='1') THEN
			curr_state <= next_state;
		END IF;
	END PROCESS;
	
	--------------Upper section FSM-------------------
	PROCESS (curr_state, nxt)
		VARIABLE count:	STD_LOGIC := '0';
	BEGIN
		CASE curr_state IS
			WHEN S0 =>
				light <= "0000001";
				IF (nxt='0' AND flag='1') THEN
					next_state <= S1;
				ELSE
					next_state <= S0;
				END IF;
			WHEN S1 =>
				light <= "0000010";
				IF (nxt='0' AND flag='1') THEN
					next_state <= S2;
				ELSE
					next_state <= S1;
				END IF;
			WHEN S2 =>
				light <= "0000100";
				IF (nxt='0' AND flag='1') THEN
					next_state <= S3;
				ELSE
					next_state <= S2;
				END IF;
			WHEN S3 =>
				light <= "0001000";
				IF (nxt='0' AND flag='1') THEN
					next_state <= S4;
				ELSE
					next_state <= S3;
				END IF;
			WHEN S4 =>
				light <= "0010000";
				IF (nxt='0' AND flag='1') THEN
					next_state <= S5;
				ELSE
					next_state <= S4;
				END IF;
			WHEN S5 =>
				light <= "0100000";
				IF (nxt='0' AND flag='1') THEN
					next_state <= S6;
				ELSE
					next_state <= S5;
				END IF;
			WHEN S6 =>
				light <= "1000000";
				IF (nxt='0' AND flag='1') THEN
					next_state <= S0;
				ELSE
					next_state <= S6;
				END IF;
		END CASE;
	END PROCESS;
	
	PROCESS (clk_20, rst)
	BEGIN
		IF (rst='0') THEN
			led_o <= "0000000";
		ELSIF (clk_20'EVENT AND clk_20='1') THEN
			led_o <= light;
		END IF;
	END PROCESS;
end Behavioral;

