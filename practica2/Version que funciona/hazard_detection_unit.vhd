library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity hazard_detection_unit is
   port(
 
	  -- Output para pc:
	  Pcwrite : out std_logic;
	  -- output para cambiar primer registro
	  Ifidwrite : out std_logic;
	  -- Para hacer el nop sobre el registro idex
	  Idexmux : out std_logic;
	  
	  --Inputs
	  Idexmemread : in std_logic;
	  Idex2016 : in std_logic_vector(4 downto 0);
	  A1: in std_logic_vector(4 downto 0);
	  A2: in std_logic_vector(4 downto 0)
   );
end hazard_detection_unit;

architecture arq of hazard_detection_unit is 
	begin

	Idexmux <= '0' when Idexmemread = '1' and (Idex2016 = A2 or Idex2016 = A1) else
				  '1';
  	Pcwrite <=  '0' when Idexmemread = '1' and (Idex2016 = A2 or Idex2016 = A1) else
				  '1';
	Ifidwrite <=  '0' when Idexmemread = '1' and (Idex2016 = A2 or Idex2016 = A1) else
				  '1';
	
		

end architecture;
