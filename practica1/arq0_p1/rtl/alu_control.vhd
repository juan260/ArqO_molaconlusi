--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2017.
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
   );
end alu_control;

architecture rtl of alu_control is
   
	   -- Codigos de control:
   constant ALU_OR   : t_aluControl := "0111";   
   constant ALU_NOT  : t_aluControl := "0101";
   constant ALU_XOR  : t_aluControl := "0110";
   constant ALU_AND  : t_aluControl := "0100";
   constant ALU_SUB  : t_aluControl := "0001";
   constant ALU_ADD  : t_aluControl := "0000";
   constant ALU_SLT  : t_aluControl := "1010";
   constant ALU_S16  : t_aluControl := "1101";

	-- Codigos de AluOp
   constant AluOp_Add = "000";
   constant AluOp_Sub = "001";
   constant AluOp_Slt = "010";
   constant AluOp_S16 = "011";

	
begin
	
	if ALUOp = AlOp_Add then
		ALUControl <= ALU_ADD;
	elsif ALUOp = AluOp_Sub then
		ALUControl <= ALU_SUB;
	elsif ALUOp = AluOp_Slt then
		ALUControl <= ALU_SLT;
	elsif ALUOp = AluOp_S16 then
		ALUControl <= ALU_S16;
	else 
		--RType
		if Funct = "100100" then
			AluControl <= ALU_AND;
		elsif Funct = "100101" then
			AluControl <= ALU_OR;
		elsif Funct = "100000" or Funct = "000000" then
			AluControl <= ALU_ADD;
		elsif Funct = "100110" then
			AluControl <= ALU_XOR;
		elsif Funct = "100010" then
			AluControl <= ALU_SUB;
		else 
			AluControl <= ALU_SLT;
		end if;
	end if;
end architecture;
