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

	-- Forwarding unit
	component ForwardingUnit is
		port(
		  
	   -- Outputs:
	  ForwardA 	 : out std_logic_vector(1 downto 0);
	  ForwardB	 : out std_logic_vector(1 downto 0);
	  
		 -- Inputs
	  idexRs 	 : in  std_logic_vector(4 downto 0);
	  idexRt	 : in  std_logic_vector(4 downto 0);
	  
	  exmemRegWrite : in  std_logic;
	  exmemRd	 : in  std_logic_vector(4 downto 0);
	  
	  memwbRegWrite	: in  std_logic;
	  memwbRd	 : in  std_logic_vector(4 downto 0)
	   );
	end component;
	
	-- hazard detection unit 

	component hazard_detection_unit is
	   port(
	 
		  -- Output para pc:
		  Pcwrite : out std_logic;
		  -- output para cambiar primer registro
		  Ifidwrite : out std_logic;
		  -- Para hacer el nop sobre el registro idex
		  Idexmux : out std_logic;
		  
		  --Inputs
		  Idexmemread : std_logic;
		  Idex2016 : std_logic_vector(4 downto 0);
		  A1: std_logic_vector(4 downto 0);
		  A2: std_logic_vector(4 downto 0)
	   );
	end component;
	-- Todos los cables que vamos a necesitar, uso minusculas para diferenciar
	
	-- PC, creo que aqui hacian falta mas cosas :(
	signal pc: std_logic_vector (31 downto 0);
	signal pcmas4: std_logic_vector (31 downto 0);
	signal pcbranch: std_logic_vector (31 downto 0);
	signal pc_aftermux: std_logic_vector (31 downto 0);	
	--signal pcjump: std_logic_vector (31 downto 0);
	signal pcnext: std_logic_vector (31 downto 0);
	--singal pcaux: std	
	signal pcwrite : std_logic;
	
	-- Las que salen de la inst memory y no van al banco de regs
	signal i_dataout: std_logic_vector(31 downto 0);
	signal opcode: std_logic_vector (31 downto 0);
	signal imm: std_logic_vector (15 downto 0);
	signal jumpoffset: std_logic_vector (27 downto 0);
		
	-- Para el banco de registros	
	signal a1: std_logic_vector ( 4 downto 0);
	signal a2: std_logic_vector ( 4 downto 0);
	signal a3: std_logic_vector ( 4 downto 0); --(a3<= a2 o rd dependiendo de mux)
	signal rd: std_logic_vector ( 4 downto 0);
	signal wd3: std_logic_vector ( 31 downto 0);
	signal rd1: std_logic_vector ( 31 downto 0); --sera tambien opa de alu
	signal rd2: std_logic_vector ( 31 downto 0);
	signal we3: std_logic;

	-- Para alu (exceptuando lo que ya tiene nombre al salir de banco reg)
	signal opb: std_logic_vector ( 31 downto 0);
	signal immext: std_logic_vector (31 downto 0); -- alusrc decide si opb es immext o rd2
	signal control: std_logic_vector (3 downto 0);
	signal zflag: std_logic;
	signal result: std_logic_vector (31 downto 0);
	
	-- Para data memory que no son ni de ctrl unit ni de alu
	signal d_dataout: std_logic_vector(31 downto 0);
	
	-- Salidas del control_unit, excepro regwrite (we3 de banco regs)
	signal branch: std_logic;
	signal jump: std_logic;
	signal regdst: std_logic;
	signal memread: std_logic;
	signal memtoreg: std_logic;
	signal aluop: std_logic_vector (2 downto 0);
	signal memwrite: std_logic;
	signal alusrc: std_logic;
	
	-- Seniales para los registros del multiciclo
	signal ifidpcmas4 : std_logic_vector(31 downto 0);
	signal ifidInstr : std_logic_vector(31 downto 0);
	signal ifidwrite : std_logic;

	signal idexwb : std_logic_vector(1 downto 0); -- 1 memtoreg 0 regwrite
	signal idexm : std_logic_vector(2 downto 0); -- 3 jam 2 branch 1 memread 0 memwrite
	signal idexex : std_logic_vector(4 downto 0); -- 4 downto 2 aluop 1 regdst 0 alusrc
	signal idexpcmas4 : std_logic_vector(31 downto 0);
	--signal idexpcjump  : std_logic_vector(31 downto 0);
	signal idexrd1 : std_logic_vector(31 downto 0);
	signal idexrd2 : std_logic_vector(31 downto 0);
	signal ideximm : std_logic_vector(31 downto 0);
	signal idex2521 : std_logic_vector(4 downto 0);
	signal idex2016 : std_logic_vector(4 downto 0);
	signal idex1511 : std_logic_vector(4 downto 0);
	signal idexmux : std_logic;
	
	signal exmemwb : std_logic_vector(1 downto 0); -- 1 memtoreg 0 regwrite
	signal exmemm : std_logic_vector(2 downto 0); -- 3 jam 2 branch 1 memread 0 memwrite
	signal exmempcbranch : std_logic_vector(31 downto 0);
	--signal exmempcjump  : std_logic_vector(31 downto 0);
	signal exmemz : std_logic;
	signal exmemresult : std_logic_vector(31 downto 0);
	signal exmemrd2 : std_logic_vector(31 downto 0);
	signal exmema3 : std_logic_vector(4 downto 0);
	
	signal memwbwb : std_logic_vector(1 downto 0); -- 1 memtoreg 0 regwrite
	signal memwbd_dataout : std_logic_vector(31 downto 0);
	signal memwbresult : std_logic_vector(31 downto 0);
	signal memwba3 : std_logic_vector(4 downto 0);
	
	-- Seniales para la forwarding Unit y sus multiplexores
	signal forwardA : std_logic_vector(1 downto 0);
	signal forwardB : std_logic_vector(1 downto 0);
	signal forwardMuxA : std_logic_vector(31 downto 0);
	signal forwardMuxB : std_logic_vector(31 downto 0);
	
begin   
	
	-- Port maps   PUERTO_COMPONENTE => TU_SIGNAL,   LA ULTIMA SIN ','
	
	miReg : reg_bank
	port map(
		Clk => Clk,
		Reset => Reset,
		A1 => a1,
		A2 => a2,
		A3 => a3,
		Wd3 => wd3,
		We3 => memwbwb(0),
		Rd1 => rd1,
		Rd2 => rd2
	);
	
	miAlu: alu
	port map(
		OpA => forwardMuxA,
		Opb => opb,
		Control => control,
		Result => result,
		ZFlag => zflag
	);
	
	miControl_unit: control_unit
	port map(
		Instr => opcode,
		Branch => branch,
		Jump => jump,
		MemToReg => memtoreg,
		MemRead => memread,
		MemWrite => memwrite,
		ALUSrc => alusrc,
		ALUOp => aluop,
		RegWrite => we3,
		RegDst => regdst
	);
	
	miAlu_control: alu_control
	port map(
		ALUOp => idexex(4 downto 2),
		Funct => ideximm(5 downto 0),
		ALUControl => control
	);
	
	miForwardingUnit: ForwardingUnit
	port map(
	  -- Outputs:
	  ForwardA => forwardA,
	  ForwardB => forwardB,
	  
	  -- Inputs
	  --NOTA RS = A1 y RD = A3
	  idexRs => idex2521,
	  idexRt => idex2016,
	  	  
	  exmemRegWrite	=> 	exmemwb(0),
	  exmemRd	=>	exmema3,
	  
	  memwbRegWrite	=> memwbwb(0),
	  memwbRd	=> memwba3
	);

	miHazard_detection_unit: hazard_detection_unit
	port map(
	  Pcwrite => pcwrite,
	  Ifidwrite => ifidwrite,
	  Idexmux => idexmux,
	  Idexmemread => idexm(1),
	  Idex2016 => idex2016,
	  A1 => a1,
	  A2 => a2
	);
	-- Ahora empezarian las asignaciones concurrentes
	
	
		 

	-- Separacion instruccion
	opcode <= i_dataout (31 downto 0);
	a1 <= i_dataout (25 downto 21);
	a2 <= i_dataout (20 downto 16);
	rd <= i_dataout (15 downto 11);
	imm <= i_dataout (15 downto 0);
	-- Mux para el write register
	a3 <= memwba3;
	-- Mux para OpB de la ALU
	opb <= forwardMuxB when idexex(0) = '0' else ideximm;
	-- Muxes de adelantamiento para la ALU
	forwardMuxA <= 	idexrd1 when forwardA = "00" else
					wd3 when forwardA = "01" else exmemresult;
	forwardMuxB <= 	idexrd2 when forwardB = "00" else
					wd3 when forwardB = "01" else exmemresult;
	-- Extendemos en signo la signal imm
	immext (15 downto 0) <= imm (15 downto 0);
	immext (31 downto 16) <= (others => imm(15));
	-- Mux de la salida del data memory
	wd3 <= memwbresult when memwbwb(1) = '0' else memwbd_dataout;
	
	-- Empezamos con el calculo del proximo PC
	pcmas4 <= pc + 4;
	pcbranch <= idexpcmas4 + ((ideximm(29 downto 0) & "00")); -- pc+4 + shiftleft2(immext)
	jumpoffset <= i_dataout(25 downto 0) & "00";
	-- Una vez tenemos pc+4, pcbranch i pcjump, hacemos muxes.
	pc_aftermux <= exmempcbranch when exmemm(2) = '1' and exmemz = '1' else
						pcmas4;
						
	
	pcnext <= (ifidpcmas4(31 downto 28) & jumpoffset(27 downto 0)) when jump = '1' else
				 pc_aftermux;
				 
    	
	--Actualizacion del pc
	process (Clk, Reset)
		begin
		--if Reset = '1' or falling_edge(Reset) then pc <= x"fffffffc"; 
		if Reset = '1' then 
			pc <= (others => '0');	
			ifidpcmas4 <= (others => '0');
			ifidInstr <= (others => '0');	
	
			idexwb <= (others => '0');	
			idexm <= (others => '0');
			idexex  <= (others => '0');
			idexpcmas4  <= (others => '0');
			--idexpcjump <= (others => '0');
			idexrd1  <= (others => '0');
			idexrd2  <= (others => '0');
			ideximm <= (others => '0');
			idex2016  <= (others => '0');
			idex1511  <= (others => '0');
			idex2521 <= (others => '0');
	
			exmemwb <= (others => '0');
			exmemm  <= (others => '0');
			exmempcbranch <= (others => '0');
			--exmempcjump <= (others => '0');
			exmemz <= '0';
			exmemresult <= (others => '0');
			exmemrd2 <= (others => '0');
			exmema3  <= (others => '0');
	
			memwbwb <= (others => '0');
			memwbd_dataout <= (others => '0');
			memwbresult <= (others => '0');
			memwba3 <= (others => '0');
	
		elsif rising_edge(Clk) then
			-- idea: 
			if pcwrite = '1'then
				pc <= pcnext;
			end if;
			

			if (idexm(2) = '1' and zflag = '1') then
				ifidInstr <= (others => '0');
				ifidpcmas4 <= (others => '0');
			elsif ifidwrite = '1' then
				ifidInstr <= IDataIn;
				ifidpcmas4 <= pc + 4;
			end if;

			-- En las 2 proximas sentencias el when else distingue
			-- el caso donde se hace nop por hazard detection (idexmux = 0)
			if idexmux = '1' then
				idexwb <= memtoreg & we3;
				idexm <= branch & memread & memwrite;
			else 
				idexwb <= memtoreg & '0';
				idexm <= branch & memread & '0';
			end if;

			idexex  <= (aluop & regdst & alusrc);
			idexpcmas4  <= ifidpcmas4;
			idexrd1  <= rd1;
			idexrd2  <= rd2;
			ideximm <= immext;
			idex2521 <= i_dataout(25 downto 21);
			idex2016  <= i_dataout(20 downto 16);
			idex1511  <= i_dataout(15 downto 11);
			--idexpcjump <= ifidpcmas4(31 downto 28) & jumpoffset(27 downto 0);
	
			exmemwb <= idexwb;
			exmemm  <= idexm;
			exmempcbranch <= pcbranch;
			--exmempcjump <= idexpcjump;
			exmemz <= zflag;
			exmemresult <= result;
			exmemrd2 <= forwardMuxB;
			if idexex(1) = '0' then
				exmema3  <= idex2016;
			else
				exmema3 <= idex1511;
			end if;

			memwbwb <= exmemwb;
			memwbd_dataout <= DDataIn;
			memwbresult <= exmemresult;
			memwba3 <= exmema3;  
		end if;
	end process;
	

	
	i_dataout <= ifidInstr;
	DAddr <= exmemresult;
	DDataOut <= exmemrd2;
	DRdEn <= exmemm(1);
	DWrEn <= exmemm(0);
	d_dataout <= DDataIn; 
	IAddr <= pc;
	

	
		
end architecture;
