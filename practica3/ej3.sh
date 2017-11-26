#!/bin/bash
# Script del ejercicio 3

P=1
NInicio=$((256+(256*P)))
NFinal=$(($NInicio+256))
NPaso=16
NRep=1
fDAT=mult.dat
fPNG=mult.png
declare -A normalTime
declare -A traspTime

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running normal and trasp..."

# array2 va 2 pasos por detras de array1. Reescribimos los 2 primeros eltos de array2 como los 2 ultimos de array1
array1=($(seq $Ninicio $Npaso $Nfinal))
array2=($(seq $(($Ninicio-2*$Npaso)) $Npaso $(($Nfinal-2*$Npaso)) ))
array2[0]=$( echo "scale = 5; $Nfinal - $Npaso" | bc -l )
array2[1]=$Nfinal
length=${#array1[@]}

for item in ${array1[@]}
do
	normalTime[$item]=0
	traspTime[$item]=0
done

echo "Midiendo los tiempos (por separado de los de los valgrinds para que no se afecten mutuamente"
for iter in $(seq 1 1 $Niter)
do
    echo "Iteracion numero $iter"
    for i in $(seq 0 1 $(($length - 1)) )
    do
        echo "Subiteracion $i : array1 ${array1[$i]} array2 ${array2[$i]}"
        
        #Ejecutamos los 2
        normal=$(./ej3 normal ${array1[$i]})
        trasp=$(./ej3 traspuesta ${array2[$i]})
        #Y sumamos los datos a las medias guardadas en los arrays
        normalTime[${array1[$i]}]=$(echo "scale = 5; ${normalTime[${array1[$i]}]} +  $normal / $Niter " | bc -l)
        traspTime[${array2[$i]}]=$(echo "scale = 5; ${traspTime[${array2[$i]}]} +  $trasp / $Niter " | bc -l)
    done
done 


for N in ${array1[@]}; do
	
	echo "Ejecutando valgrind para medir los fallos de cache" 
	valgrind --tool=cachegrind -q --cachegrind-out-file=normalTmp.dat ./normal $N
	echo "Ejecutando valgrind para medir los fallos de cache de las traspuestas"
	valgrind --tool=cachegrind -q --cachegrind-out-file=traspTmp.dat ./trasp $N

	echo -e "$N ${normalTime[$N]} $(cg_annotate normalTmp.dat | sed 's/,//g'| head -n 18 | tail -n 1 | cut --delimiter=\  -f 5,8 ) \
${traspTime[$N]} $(cg_annotate traspTmp.dat | sed 's/,//g'| head -n 18 | tail -n 1 | cut --delimiter=\  -f 5,8)" >> $fDAT

done

gnuplot << END_GNUPLOT
set title "Matrix Multiplication Data Cache Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "mult_cache.png"
plot "$fDAT" using 1:3 with lines lw 2 title "./normal read misses", \
    "$fDAT" using 1:4 with lines lw 2 title "./normal write misses", \
    "$fDAT" using 1:6 with lines lw 2 title "./trasp read misses", \
    "$fDAT" using 1:7 with lines lw 2 title "./trasp write misses"
    
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Matrix Multiplication Time"
set ylabel "Time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "mult_time.png"
plot "$fDAT" using 1:2 with lines lw 2 title "./normal time", \
    "$fDAT" using 1:5 with lines lw 2 title "./trasp time"
    
replot
quit
END_GNUPLOT
