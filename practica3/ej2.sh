#!/bin/bash
# Script del ejercicio2

# Inicializar variables
P=3
Ninicio=$((2000+(1024*$P)))
Nfinal=$(($Ninicio+1024))
Npaso=64
fPNGlect=cache_lectura.png
fPNGescr=cache_escritura.png
NTamanios=4
declare -A slowTime
declare -A fastTime

# borrar el fichero DAT y el fichero PNG
rm -f *.dat


array1=$(seq $Ninicio $Npaso $Nfinal)

for N in ${array1[@]}; do

    NBytes=1024
    for tam in $(seq $NTamanios); do
    #NOTA: se ha supuesto que la cache de instrucciones y de datos varian a la misma frecuencia
        
        echo -e "\nEjecutando valgrind para ./slow, tamaño de matriz $N y tamaño de cache $NBytes..."
        valgrind --tool=cachegrind -q --cachegrind-out-file=slowTmp.dat --I1=$NBytes,1,64 --D1=$NBytes,1,64 --LL=8388608,1,64 ./slow $N
        echo -e "\nEjecutando valgrind para ./fast, tamaño de matriz $N y tamaño de cache $NBytes..."
        valgrind --tool=cachegrind -q --cachegrind-out-file=fastTmp.dat --I1=$NBytes,1,64 --D1=$NBytes,1,64 --LL=8388608,1,64 ./fast $N
        touch cache_$NBytes.dat
        echo -e "$N $(cg_annotate slowTmp.dat | sed 's/,//g' | head -n 18 | tail -n 1 | cut --delimiter=\  -f 5,8 ) \
$(cg_annotate fastTmp.dat | sed 's/,//g'| head -n 18 | tail -n 1 | cut --delimiter=\  -f 5,8)" >> cache_$NBytes.dat
        NBytes=$(($NBytes*2))


    done
done

gnuplot << END_GNUPLOT
set title "Slow-Fast Read Data Cache Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGlect"
plot "cache_1024.dat" using 1:2 with lines lw 2 title "./slow with 1024B", \
    "cache_2048.dat" using 1:2 with lines lw 2 title "./slow with 2048B", \
    "cache_4096.dat" using 1:2 with lines lw 2 title "./slow with 4096B", \
    "cache_8192.dat" using 1:2 with lines lw 2 title "./slow with 8192B", \
    "cache_1024.dat" using 1:4 with lines lw 2 title "./fast with 1024B", \
    "cache_2048.dat" using 1:4 with lines lw 2 title "./fast with 2048B", \
    "cache_4096.dat" using 1:4 with lines lw 2 title "./fast with 4096B", \
    "cache_8192.dat" using 1:4 with lines lw 2 title "./fast with 8192B"
    
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Slow-Fast Write Data Cache Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGescr"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "./slow with 1024B", \
    "cache_2048.dat" using 1:3 with lines lw 2 title "./slow with 2048B", \
    "cache_4096.dat" using 1:3 with lines lw 2 title "./slow with 4096B", \
    "cache_8192.dat" using 1:3 with lines lw 2 title "./slow with 8192B", \
    "cache_1024.dat" using 1:5 with lines lw 2 title "./fast with 1024B", \
    "cache_2048.dat" using 1:5 with lines lw 2 title "./fast with 2048B", \
    "cache_4096.dat" using 1:5 with lines lw 2 title "./fast with 4096B", \
    "cache_8192.dat" using 1:5 with lines lw 2 title "./fast with 8192B"
    
replot
quit
END_GNUPLOT

rm -f slowTmp.dat fastTmp.dat
