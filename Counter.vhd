LIBRARY ieee;						--	step = (2^N * freq) / CLK = (2^16 * 650E3) / 50E6 = 852 = "1101010100"
USE ieee.std_logic_1164.all;	-- upperlimit = (2^16 * 660E3) / 50E6 = 865 = "1101100001"
USE ieee.numeric_std.all;		-- lowerlimit = (2^16 * 640E3) / 50E6 = 839 = "1101000111"
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Counter is
   port(
			clk           	 	:  IN    STD_LOGIC;                                
			reset          	:  IN    STD_LOGIC; 
			distance				:	IN		STD_LOGIC_VECTOR(12 downto 0);
			switch				:	IN		STD_LOGIC_VECTOR(0 downto 0);		--0=FM, 1=AM
			counter				:	OUt	STD_logic_VECTOR(9 downto 0)
		);
end Counter;

architecture behavior OF Counter IS
	--Signals
	signal counter16	: STD_logic_VECTOR (15 downto 0) := "0000000000000000";
	signal offset		:	STD_LOGIC_VECTOR(9 downto 0);
	
	--Components
	component Distance2Offset IS
   port (
			clk            :  IN    STD_LOGIC;                                
			reset          :  IN    STD_LOGIC; 
			distance       :  IN    STD_LOGIC_VECTOR(12 DOWNTO 0);                           
			offset         :  OUT   STD_LOGIC_VECTOR(9 DOWNTO 0)
		  );  
	end component;
	
begin

	D2O	:	Distance2Offset
   port map (	clk			=>	clk,
					reset			=>	reset,
					distance		=>	distance,
					offset		=>	offset
		  );

	count : process(clk, reset, counter16)
		begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				counter16 <= "0000000000000000";
			elsif (switch(0) = '0') then	--FM
				counter16 <= counter16 + offset;
			else									--AM
				counter16 <= counter16 + "1101010100";
			end if;		
		end if;
		counter <= counter16(15 downto 6);
	end process;
end behavior;