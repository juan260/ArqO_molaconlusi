--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2017-18
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is 
	--Componentes que necesitamos:
	-- control_unit
	-- reg_bank
	-- alu_control
	-- alu
	
	-- CONTROL UNIT
	component control_unit is
		port(
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
	end component;
	
	-- REG_BANK
	component reg_bank is
		port(
			Clk   : in std_logic; -- Reloj activo en flanco de subida
		   Reset : in std_logic; -- Reset asíncrono a nivel alto
		   A1    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
		   Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
		   A2    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
		   Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
		   A3    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
		   Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
		   We3   : in std_logic -- Habilitación de la escritura de Wd3
		);
	end component;
	
	-- ALU_CONTROL
	component alu_control is
		port(
			-- Entradas:
		   ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
		   Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
		   -- Salida de control para la ALU:
		   ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
		);
	end component;
	
	-- ALU
	component alu is
		port(
			OpA     : in  std_logic_vector (31 downto 0); -- Operando A
		   OpB     : in  std_logic_vector (31 downto 0); -- Operando B
		   Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
		   Result  : out std_logic_vector (31 downto 0); -- Resultado
		   ZFlag   : out std_logic                       -- Flag Z
		);
	end component;

	-- Todos los cables que vamos a necesitar, uso minusculas para diferenciar
	
	-- PC, creo que aqui hacian falta mas cosas :(
	signal pc std_logic_vector (31 downto 0);
	signal pcmas4 std_logic_vector (31 downto 0);
	signal pcbranch std_logic_vector (31 downto 0);
	signal pc_aftermux std_logic_vector (31 downto 0);	
	signal pcjump std_logic_vector (31 downto 0);
	signal pcnext std_logic_vector (31 downto 0);	
	
	-- Las que salen de la inst memory y no van al banco de regs
	signal i_dataout std_logic_vector(31 downto 0);
	signal opcode std_logic_vector (5 downto 0);
	signal imm std_logic_vector (15 downto 0);
	signal jumpoffset std_logic_vector (27 downto 0);
		
	-- Para el banco de registros	
	signal a1 std_logic_vector ( 4 downto 0);
	signal a2 std_logic_vector ( 4 downto 0);
	signal a3 std_logic_vector ( 4 downto 0); --(a3<= a2 o rd dependiendo de mux)
	signal rd std_logic_vector ( 4 downto 0);
	signal wd3 std_logic_vector ( 4 downto 0);
	signal rd1 std_logic_vector ( 31 downto 0); --sera tambien opa de alu
	signal rd2 std_logic_vector ( 31 downto 0);
	
	-- Para alu (exceptuando lo que ya tiene nombre al salir de banco reg)
	signal opb std_logic_vector ( 31 downto 0);
	signal immext std_logic_vector (31 downto 0); -- alusrc decide si opb es immext o rd2
	signal control std_logic_vector (3 downto 0);
	signal zflag std_logic;
	signal result std_logic_vector (31 downto 0);
	
	-- Para data memory que no son ni de ctrl unit ni de alu
	signal d_dataout std_logic_vector(31 downto 0);
	
	-- Salidas del control_unit, excepro regwrite (we3 de banco regs)
	signal branch std_logic;
	signal jump std_logic;
	signal regdst std_logic;
	signal memread std_logic;
	signal memtoreg std_logic;
	signal aluop std_logic_vector (2 downto 0);
	signal memwrite std_logic;
	signal alusrc std_logic;
	
begin   
	
	-- Port maps   PUERTO_COMPONENTE => TU_SIGNAL,   LA ULTIMA SIN ','
	
	reg : reg_bank
	port map(
		Clk => Clk,
		Reset => Reset,
		A1 => a1,
		A2 => a2,
		A3 => a3,
		Wd3 => wd3,
		We3 => we3,
		Rd1 => rd1,
		Rd2 => rd2
	);
	
	alu: alu
	port map(
		OpA => rd1,
		Opb => opb,
		Control => control,
		Result => result,
		ZFlag => zflag
	);
	
	ctrl_unit: control_unit
	port map(
		OpCode => opcode,
		Branch => branch,
		Jump => jump,
		MemToReg => memtoreg,
		MemRead => memread,
		ALUSrc => alusrc,
		ALUOp => aluop,
		RegWrite => we3,
		RegDst => regdst,
		MemWrite => memwrite
	);
	
	alu_control: alu_control
	port map(
		ALUOp => aluop,
		Funct => imm(5 downto 0),
		ALUControl => control
	);
	
	
	-- Ahora empezarian las asignaciones concurrentes
	
	-- Separacion instruccion
	opcode <= i_dataout (31 downto 26);
	a1 <= i_dataout (25 downto 21);
	a2 <= i_dataout (20 downto 16);
	rd <= i_dataout (15 downto 11);
	imm <= i_dataout (15 downto 0);
	-- Mux para el write register
	a3 <= a2 when regdst = '0' else rd;
	-- Mux para OpB de la ALU
	opb <= rd2 when alusrc = '0' else immext;
	-- Extendemos en signo la signal imm
	immext (15 downto 0) <= imm (15 downto 0);
	immext (31 downto 16) <= (others => imm(15));
	-- Mux de la salida del data memory
	wd3 <= result when memtoreg = '0' else d_dataout;
	
	-- Empezamos con el calculo del proximo PC
	pcmas4 <= pc + 4,
	pcbranch <= pcmas4 + (immext & "00"); -- pc+4 + shiftleft2(immext)
	jumpoffset <= i_dataout(25 downto 0) & "00";
	pcjump <= pcmas4(31 downto 28) & jumoffset(27 downto 0);
	-- Una vez tenemos pc+4, pcbranch i pcjump, hacemos muxes.
	pc_aftermux <= pcbranch when branch = '1' and zflag = '1' else
						pcmas4;
	pcnext <= pcjump when jump = '1' else
				 pc_aftermux;
				 
	process (Clk, Reset)
		begin
		if Reset = '0' then pc <= (others => '0'); --No seria reset = '1'?
		if rising_edge(Clk) then
		    pc <= pcnext;
		end if;
	end process;
	
	
	
	-- ¿Y unir los ports de la entity con las signals y eso?
	-- Tu crees que seria algo asi:
	DAddr <= result;
	DDataOut <= rd2;
	DRdEn <= memread;
	DWrEn <= memwrite;
	d_dataout <= DDataIn; 
	IAddr <= pc;
	i_dataout <= IDataIn;
	
		
end architecture;
