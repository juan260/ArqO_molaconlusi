library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity ForwardingUnit is
   port(
 
	  -- Outputs:
	  ForwardA 	 : out std_logic_vector(1 downto 0);
	  ForwardB	 : out std_logic_vector(1 downto 0);
	  ForwardA2	 : out std_logic_vector(1 downto 0);
	  ForwardB2	 : out std_logic_vector(1 downto 0);
	  -- Inputs
	  idexRs 	 : in  std_logic_vector(4 downto 0);
	  idexRt	 : in  std_logic_vector(4 downto 0);
	  idexRw	 : in std_logic;

	  exmemRegWrite : in  std_logic;
	  exmemRd	 : in  std_logic_vector(4 downto 0);
	  
	  memwbRegWrite	: in  std_logic;
	  memwbRd	 : in  std_logic_vector(4 downto 0);
	  -- Inputs extra para kkbeq
	  Ifid2521 : in std_logic_vector(4 downto 0); -- ifidrs
	  Ifid2016 : in std_logic_vector(4 downto 0); -- ifidrt
	  
	  Idexrd : in std_logic_vector(4 downto 0)
   );
end ForwardingUnit;

architecture arqFor of ForwardingUnit is 
	begin

		--ForwardA

			--EX hazard
		ForwardA <= "10" when ((exmemRegWrite = '1' and (exmemRd /= 0))
								and (exmemRd = idexRs)) else	
			--MEM hazard
					"01" when ((memwbRegWrite = '1' and (memwbRd /= 0)) 
								and (memwbRd = idexRs)) else "00";
		
		--ForwardB
		
			--EX hazard
		ForwardB <= "10" when ((exmemRegWrite = '1' and (exmemRd /= 0))
								and (exmemRd = idexRt)) else
				
			--MEM hazard
					"01" when ((memwbRegWrite = '1' and (memwbRd /= 0))
								and (memwbRd = idexRt)) else "00";
		-- ForwardA2

		 ForwardA2 <= "00" when ((idexRw = '1' and (idexRd /= 0)) and (idexRd = ifid2521)) else
				"01" when ((exmemRegWrite = '1' and (exmemRd /= 0)) and (exmemRd = ifid2521)) else
				"10"  when ((memwbRegWrite = '1' and (memwbRd /= 0)) and (memwbRd = ifid2521)) else
				"00";

		-- ForwardB2

		 ForwardB2 <= "00" when (idexRw = '1' and (idexRd /= 0 and idexRd = ifid2016)) else
				"01" when (exmemRegWrite = '1' and (exmemRd /= 0 and exmemRd = ifid2016)) else
				"10"  when (memwbRegWrite = '1' and (memwbRd /= 0 and memwbRd = ifid2016)) else
				"00";
		

end architecture;