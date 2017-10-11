
library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity prueba is
   generic (
      INIT_FILENAME_INST : string   := "instrucciones"; -- Fichero con las instrucciones
      INIT_FILENAME_DATA : string   := "datos";         -- Fichero con los datos
      N_CYCLES           : positive := 100              -- Numero de ciclos a ejecutar
   );
end prueba;

architecture of prueba if