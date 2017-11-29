#!/bin/bash
#Script maestro que llama a los demas

#Eliminamos archivos temporales
rm -f *.dat *.png

make

echo -e "\n\n-----------------------------Ejecutando ejercicio 1\n\n"
./ej1.sh

echo -e "\n\n-----------------------------Ejecutando ejercicio 2\n\n"
./ej2.sh

echo -e "\n\n-----------------------------Ejecutando ejercicio 3\n\n"
./ej3.sh


echo -e "\n\n-----------------------------Ejecucion terminada $LOGNAME\n\n"


