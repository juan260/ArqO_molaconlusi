#!/bin/bash
# Script del ejercicio2

# inicializar variables
P=5
Ninicio=$((2000+(1024*$P)))
Nfinal=$(($Ninicio+1024))
Npaso=64
Niter=5
fPNGlect=cache_lectura.png
fPNGescr=cache_escritura.png
#BORRAR siguiente linea tiene que ser 4
NTamanios=2

declare -A slowTime
declare -A fastTime

# borrar el fichero DAT y el fichero PNG
rm -f *.dat


array1=$(seq $Ninicio $Npaso $Nfinal)
#BORRAR siguiente linea
array1=$(seq 10 1 20)

for N in ${array1[@]}; do

#BORRAR la proxima linea sin comentar y descomentar la proxima linea
    #for tam in $(seq 4); do
    NBytes=1024
    for tam in $(seq $NTamanios); do
    #NOTA: se ha supuesto que la cache de instrucciones y de datos varian a la misma frecuencia
        
        echo -e "\nEjecutando valgrind para ./slow, tamaño de matriz $N y tamaño de cache $NBytes..."
        valgrind --tool=cachegrind -q --cachegrind-out-file=slowTmp.dat --I1=$NBytes,1,64 --D1=$NBytes,1,64 --LL=8388608,1,64 ./slow $N
        echo -e "\nEjecutando valgrind para ./fast, tamaño de matriz $N y tamaño de cache $NBytes..."
        valgrind --tool=cachegrind -q --cachegrind-out-file=fastTmp.dat --I1=$NBytes,1,64 --D1=$NBytes,1,64 --LL=8388608,1,64 ./fast $N
        touch cache_$NBytes.dat
        echo -e "$N $(cg_annotate slowTmp.dat | head -n 18 | tail -n 1 | cut --delimiter=\  -f 5,8 ) \
$(cg_annotate fastTmp.dat | head -n 18 | tail -n 1 | cut --delimiter=\  -f 5,8)" >> cache_$NBytes.dat
        NBytes=$(($NBytes*2))


    done
done


gnuplot << END_GNUPLOT
set title "Slow-Fast data cache misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGlect"
tamanio = 1024
do for [i=1:$NTamanios] { 
    datos = sprintf("cache_%d.dat", tamanio);
    titulo1 = sprintf("slow, %d Bytes", tamanio);
    titulo2 = sprintf("fast, %d Bytes", tamanio);
    plot datos using 1:2 with lines lw 2 title titulo1, \
    datos using 1:4 with lines lw 2 title titulo2
    tamanio = tamanio * 2
    }
replot
quit
END_GNUPLOT

rm -f thrash.tmp
