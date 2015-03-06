----------------------------------------------------------------------------------
-- Company: University of Southern Denmark
-- Engineer: Anders Blaabjerg Lange
-- 
-- Create Date:    12:20:44 21/12-2011 
-- Design Name: 	 
-- Module Name:    log_pkg - package 
-- Project Name: 	 
-- Target Devices: 
-- Tool versions:  
-- Description: 	 
--
-- Dependencies:
--
-- Revision History:
-- -----------------------------------------
-- Version		Date			Author	Comment
-- 0.01 			21/12-2012 	ANLAN		File Created
-- 
--
-- Additional Comments: 
--
-- -----------------------------------------------------------------------------
-- Licensing:     (c) Copyright 2011, Anders Blaabjerg Lange
--                            All Rights Reserved
--
--  This file is part of the Unity HDL Library (Unity-lib).
--
--  Unity-lib is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  Unity-lib is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with Unity-lib.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package log_pkg is
	function log2c (n: integer) return integer;
	function log2r (n: integer) return integer;
	function log2i (n: integer) return integer;
end log_pkg;

package body log_pkg is
   
	-- Calculates the standard 'exclusive' power of two logarithm (log2) of the given integer argument
	-- N.B. this function returns the number of bits necesarry to represent the values in the range [0:n-1]
	function log2c(n: integer) return integer is
		variable m, p: integer := 0;
	begin
		m := 0;
		p := 1;
		while p < n loop
			m := m + 1;
			p := p * 2;
		end loop;
		return m;
	end log2c;
	
	-- Calculates the power of two logarithm (log2) of the given integer argument
	-- N.B. the minimum returned value is 1, i.e. if the result is zero a 1 will still be returned, use to avoid empty ranges
	function log2r(n: integer) return integer is
      variable m, p: integer := 0;
	begin
		m := 0;
		p := 1;
		while p < n loop
			m := m + 1;
			p := p * 2;
		end loop;
		if m = 0 then
			return 1;
		else
			return m;
		end if;
	end log2r;
	
	-- Calculates the 'inclusive' power of two logarithm (log2) of the given integer argument
	-- N.B. this function returns the number of bits necesarry to represent the values in the range [0:n] 
	function log2i(n: integer) return integer is
		variable m, p: integer := 0;
	begin
		m := 0;
		p := 1;
		while (p-1) < n loop
			m := m + 1;
			p := p * 2;
		end loop;
		return m;
	end log2i;	
	
end log_pkg;