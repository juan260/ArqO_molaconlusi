#!/bin/bash

# inicializar variables
P=5
Ninicio=$((10000+(1024*$P)))
Nfinal=$(($Ninicio+1024))
Npaso=64
Niter=15
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png

declare -A slowTime
declare -A fastTime

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."

# array2 va 2 pasos por detras de array1. Reescribimos los 2 primeros eltos de array2 como los 2 ultimos de array1
array1=($(seq $Ninicio $Npaso $Nfinal))
array_fast=($(seq $($Ninicio-2*$Npaso) $Npaso $($Nfinal-2*$Npaso))
array_fast[0]=$(($Nfinal-$NPaso))
array_fast[1]=$Nfinal
length=${#array1[@]}

for iter in $(seq 1 1 $Niter)
do
    echo "Iteracion numero $iter"
    for i in $(seq 0 1 $(($length - 1)) )
    do
        echo "Subiteracion $i : array1 ${array1[$i]} array2 ${array2[$i]}"
        
        #Ejecutamos los 2
        slow=$(./slow   ${array1[$i]} | grep Execution | cut --delimiter=\  -f 3)
        fast=$(./fast ${array_fast[$i]} | grep  Execution | cut --delimiter=\  -f 3)
        #Y sumamos los datos a las medias guardadas en los arrays
        slowTime[${array1[$i]}]+=$(bc <<< "sale = 5; $slow / $Niter ")
        fastTime[${array_fast[$i]}]+=$(bc <<< "sale = 5; $fast / $Niter ")]
    done
done 

for key in "${!array1[@]}"
do
    echo "$key ${slowTime[$key]} ${fastTime[$key]}" >> $fDAT    
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
