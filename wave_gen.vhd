library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

entity wave_gen is
	Port (	clk									:	in STD_LOGIC;
				reset					 				:	in STD_LOGIC;								--[S0]
				switchUS								:	in	STD_LOGIC_VECTOR(0 downto 0);		--0=FM, 1=AM
				ARDUINO_IO							:	out std_logic_vector(9 downto 0);
			   LEDR                          :	out STD_LOGIC_VECTOR (9 downto 0);
			   HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 :	out STD_LOGIC_VECTOR (7 downto 0)
          );
end wave_gen;

architecture Behavioral of wave_gen is
	--Signals
	signal duty_cycle,	duty_cycle_scaled 	: STD_LOGIC_VECTOR(9 downto 0);
	signal counteri									: STD_logic_VECTOR (9 downto 0);
	signal distance									: STD_LOGIC_VECTOR (12 downto 0);
	signal switch										: STD_LOGIC_VECTOR(0 downto 0);		--0=FM, 1=AM
	
	--Components
	component Count2Cycle is
		port( clk            :  IN    STD_LOGIC;                                
				reset          :  IN    STD_LOGIC;
				Counter      	:  IN    STD_LOGIC_VECTOR(9 DOWNTO 0);                           
				DutyCycle      :  OUT   STD_LOGIC_VECTOR(9 DOWNTO 0)
			);
	end component ;

	component Synchronizer is
		generic(	InputSyncRegisterCount : integer := 2;
					Bits	:	integer	:=	1
				);
		port(	clk		:	in  STD_LOGIC;
				reset		:	in  STD_LOGIC;
				input		:	in		std_logic_vector(Bits-1 downto 0);
				output	:	out	std_logic_vector(Bits-1 downto 0)
			);
	end component;

	component voltmeter is
		generic (register_count : integer := 2);
		port ( clk                           : in  STD_LOGIC;
             reset                         : in  STD_LOGIC;
			    S									    : in  STD_LOGIC_VECTOR(0 downto 0);
			    switch								 : in  STD_LOGIC_VECTOR(0 downto 0);	--0=FM, 1=AM
             LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
             HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0);
				 distance_out						 : out STD_LOGIC_VECTOR (12 downto 0)
            );
	end component;
	
	component Counter is
		port(
			clk           	 	:  IN    STD_LOGIC;
			reset          	:  IN    STD_LOGIC;
			distance				:	IN		STD_LOGIC_VECTOR(12 downto 0);
			switch				:	IN		STD_LOGIC_VECTOR(0 downto 0);		--0=FM, 1=AM
			counter				:	OUt	STD_logic_VECTOR(9 downto 0)
		);
	end component;

	component Scaler is
		port(	clk           	 	:  IN    STD_LOGIC;                                
				reset          	:  IN    STD_LOGIC;
				switch				:	in		STD_LOGIC_VECTOR(0 downto 0);		--0=FM, 1=AM
				dutyin				:	in		STD_logic_vector(9 downto 0);
				distance				:	in		Std_Logic_Vector(12 downto 0);
				dutyout				:	out	STD_logic_vector(9 downto 0)
		);
	end component;

begin

	C2C : 	Count2Cycle
		port map(	clk 			=> clk,
						reset 		=> reset,
						Counter 		=> counteri,
						DutyCycle 	=> duty_cycle
					);

	voltage : voltmeter
		generic map (register_count => 2)
		port map( clk 	 			  => clk,
					 reset 			  => reset,
					 S	     			  => "0",
					 switch			  => switch,	--0=FM, 1=AM
					 LEDR 			  => LEDR,
					 HEX0 			  => HEX0,
					 HEX1 			  => HEX1,
					 HEX2 			  => HEX2,
					 HEX3 			  => HEX3,
					 HEX4 			  => HEX4,
					 HEX5 			  => HEX5,
					 distance_out	  => distance
					);
	
	count	:	Counter
		port map(	clk			=>	clk,
						reset			=>	reset,
						distance		=>	distance,
						switch		=>	switch,
						counter		=>	counteri
		);

	sync	:	Synchronizer
		generic map(	InputSyncRegisterCount => 2,
							Bits	=>	1
						)
		port map(	clk		=>	clk,
						reset		=>	reset,
						input		=>	switchUS,
						output	=>	switch
					);
	
	scale	:	Scaler
		port map(	clk		=>	clk,
						reset		=>	reset,
						switch	=>	switch,
						dutyin	=>	duty_cycle,
						distance	=>	distance,
						dutyout	=>	duty_cycle_scaled
		);

ARDUINO_IO	<= duty_cycle_scaled;
	 
end Behavioral;