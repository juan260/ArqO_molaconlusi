--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2017
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode  : in  std_logic_vector (5 downto 0);
      -- Seniales para el PC
      Branch : out  std_logic; -- 1 = Ejecutandose instruccion branch
      Jump : out std_logic; -- 1 = Ejecutandose un jump
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0 = oper.B es registro, 1=es valor inm.
      ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic  -- 0=Reg. destino es rt, 1=rd
   );
end control_unit;

architecture rtl of control_unit is

   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);
   subtype t_aluControl is std_logic_vector (2 downto 0);

   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_BEQ    : t_opCode := "000100";
   constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";
   constant OP_JUMP   : t_opCode := "000010";
   constant OP_SLTI   : t_opCode := "001010";

   -- Codigos de AluOp
   constant AluOp_Add : t_aluControl := "000";
   constant AluOp_Sub : t_aluControl := "001";
   constant AluOp_Slt : t_aluControl := "010";
   constant AluOp_S16 : t_aluControl := "011";
   constant AluOp_RType : t_aluControl := "111";

begin
   process(OpCode)
   begin

	--Branch
	if OpCode = OP_BEQ then
		Branch <= '1';
	else 
		Branch <= '0';
	end if;

		
	--MemToReg
	if OpCode = OP_LW then
		MemToReg <= '1';
	else
		MemToReg <= '0';
	end if;

	--MemWrite
	if OpCode = OP_SW then
		MemWrite <= '1';
	else 
		MemWrite <= '0';
	end if;

	--MemRead
	if OpCode = OP_LW then
		MemRead <= '1';
	else
		MemRead <= '0';
	end if;

	--AluSrc
	if OpCode = OP_RTYPE or OpCode = OP_BEQ  then
		AluSrc <= '0';
	else
		AluSrc <= '1';
	end if;

	--RegWrite
	if OpCode = OP_SW or OpCode = OP_BEQ or	
	   OpCode = OP_JUMP then
		RegWrite <= '0'; 
	else 
		RegWrite <= '1';
	end if;

	--RegDst
	if OpCode = OP_RTYPE then
		RegDst <= '1';
	else
		RegDst <= '0';
	end if;

	--Jump
	if OpCode = OP_JUMP then
		Jump <= '1';
	else 
		Jump <= '0';
	end if;
	
	--AluOp
	if OpCode = OP_RTYPE then
		AluOp <= AluOp_RType;
	elsif OpCode = OP_SLTI then
		AluOp <= AluOp_Slt;
	elsif OpCode = OP_BEQ then
		AluOp <= AluOp_Sub;
	else 
		AluOp <= AluOp_Add;
	end if;

    end process;
end architecture;
