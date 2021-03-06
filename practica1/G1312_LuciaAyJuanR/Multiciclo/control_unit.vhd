--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2017
--
-- Lusia y Juana
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      Instr  : in  std_logic_vector (31 downto 0);
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
   
   signal OpCode: std_logic_vector(5 downto 0);

begin
  
  OpCode <= Instr(31 downto 26);
  
  
	--Branch
	Branch <= '1' when OpCode = OP_BEQ  else
	          '0';
		
	--MemToReg
	MemToReg <= '1' when OpCode = OP_LW else
	            '0';

	--MemWrite
	MemWrite <= '1' when OpCode = OP_SW else
	            '0';

	--MemRead
	MemRead <= '1' when OpCode = OP_LW else
	           '0';

	--AluSrc
	AluSrc <= '0' when OpCode = OP_RTYPE or OpCode = OP_BEQ else
	          '1';

	--RegWrite
	RegWrite <= '0' when  OpCode = OP_SW or OpCode = OP_BEQ or	
	   OpCode = OP_JUMP or Instr = "00000000000000000000000000000000" else
	            '1';

	--RegDst
	RegDst <= '1' when OpCode = OP_RTYPE else 
	          '0';

	--Jump
	Jump <= '1' when OpCode = OP_JUMP else
          	'0';
	
	--AluOp
	AluOp <= AluOp_RType when OpCode = OP_RTYPE else
	         AluOp_Slt when OpCode = OP_SLTI else
	         AluOp_Sub when OpCode = OP_BEQ else
	         AluOp_S16 when OpCode = Op_LUI else
           AluOp_Add;
	
end architecture;
