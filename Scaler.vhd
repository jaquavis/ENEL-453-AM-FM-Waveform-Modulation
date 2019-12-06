LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Scaler is
   port(	clk           	 	:  IN    STD_LOGIC;                                
			reset          	:  IN    STD_LOGIC;
			switch				:	in		STD_LOGIC_VECTOR(0 downto 0);		--0=FM, 1=AM
			dutyin				:	in		STD_logic_vector(9 downto 0);
			distance				:	in		Std_Logic_Vector(12 downto 0);
			dutyout				:	out	STD_logic_vector(9 downto 0)
		);
end Scaler;

architecture behavior of Scaler is
	--Signals
	constant zeroes : std_logic_vector(12 downto 0) := "0000000000000"; 
begin
	scale	:	process(clk)
		begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				dutyout <= "0000000000";
			else
				if (switch(0) = '0') then	--FM
					dutyout	<=	dutyin;
				else 	--AM
					if distance = zeroes then
						dutyout <= dutyin;
					else
						dutyout <= std_logic_vector(to_unsigned((to_integer(unsigned(distance)) * to_integer(unsigned(dutyin)))/(4096), 10));
					end if;
				end if;
			end if;		
		end if;
	end process;
end behavior;