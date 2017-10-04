----------------------------------------------------------------------
-- Fichero: unidaddecontrol.vhd
-- Descripción: UC para el MIPS

-- Autores: Lucia Asencio y Rodrigo De Pool 
-- Asignatura: E.C. 1º grado
-- Grupo de Prácticas:2102
-- Grupo de Teoría:210
-- Práctica: 5
-- Ejercicio: 3
----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity UnidadControl is
	port(OPCode : in  std_logic_vector (5 downto 0); -- OPCode de la instrucción
		Funct : in std_logic_vector(5 downto 0); -- Funct de la instrucción
		
		-- Señales para el PC
		Jump : out  std_logic;
		RegToPC : out std_logic;
		Branch : out  std_logic;
		PCToReg : out std_logic;
		
		-- Señales para la memoria
		MemToReg : out  std_logic;
		MemWrite : out  std_logic;
		
		-- Señales para la ALU
		ALUSrc : out  std_logic;
		ALUControl : out  std_logic_vector (2 downto 0);
		ExtCero : out std_logic;
		
		-- Señales para el GPR
		RegWrite : out  std_logic;
		RegDest : out  std_logic
		);
end UnidadControl;

architecture pract5ej2 of UnidadControl is

begin
	process(OPCode,Funct)
	begin
		if OPCode="100011" then
			MemToReg<='1';
		else
			MemToReg<='0';
		end if;

		if OPCode="101011" then
			MemWrite<='1';
		else
			MemWrite<='0';
		end if;

		if OPCode="000100" then
			Branch<='1';
		else
			Branch<='0';
		end if;

		if OPCode="000000" or OPCode="000100" then
			ALUSrc<='0';
		else
			ALUSrc<='1';
		end if;
		
		if OPCode="000000" then
			RegDest<='1';
		else
			RegDest<='0';
		end if;

		if OPCode="101011" or OPCode="000100" or OPCode="000010" or (OPCode="000000" and Funct="001000") then
			RegWrite<='0';
		else 
			RegWrite<='1';
		end if;

		if OPCode="000000" and Funct="001000" then
			RegToPC<='1';
		else
			RegToPC<='0';
		end if ;

		if OPCode="001100" or OPCode="001110" then
			ExtCero<='1';
		else
			ExtCero<='0';
		end if;

		if OPCode="000010" or OPCode="000011" then
			jump<='1';
		else
			jump<='0';
		end if;

		if OPCode="000011" then
			PCtoReg<='1';
		else
			PCtoReg<='0';
		end if;

		if OPCode="000100" or OPCode="001010" or (OPCode="000000" and (Funct="100010" or Funct="100111" or Funct="101010")) then
			ALUControl(2)<='1';
		else
			ALUControl(2)<='0';
		end if;

		if OPCode="001100" or (OPCode="000000" and (Funct="100100" or Funct="100111")) then
			ALUControl(1)<='0';
		else
			ALUControl(1)<='1';
		end if;
		
		
		if  OPCode="001110" or OPCode="001010" or (OPCode="000000" and (Funct="100111" or Funct="100110" or Funct="101010" )) then
			ALUControl(0)<='1';
		else
			ALUControl(0)<='0';
		end if;

	end process;

end pract5ej2;
