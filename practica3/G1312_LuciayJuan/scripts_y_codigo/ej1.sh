#/bin/bash

# inicializar variables
P=3
Ninicio=$((10000+(1024*$P)))
Nfinal=$(($Ninicio+1024))
Npaso=64
Niter=20
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png

declare -A slowTime
declare -A fastTime

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."

# array2 va 2 pasos por detras de array1. Reescribimos los 2 primeros eltos de array2 como los 2 ultimos de array1
array1=($(seq $Ninicio $Npaso $Nfinal))
array2=($(seq $(($Ninicio-2*$Npaso)) $Npaso $(($Nfinal-2*$Npaso)) ))
array2[0]=$( echo "scale = 5; $Nfinal - $Npaso" | bc -l )
array2[1]=$Nfinal
length=${#array1[@]}

for item in ${array1[@]}
do
	slowTime[$item]=0
	fastTime[$item]=0
done

for iter in $(seq 1 1 $Niter)
do
    echo "Iteracion numero $iter"
    for i in $(seq 0 1 $(($length - 1)) )
    do
        echo "Subiteracion $i : array1 ${array1[$i]} array2 ${array2[$i]}"
        
        #Ejecutamos los 2
        slow=$(./slow   ${array1[$i]} | grep Execution | cut --delimiter=\  -f 3)
        fast=$(./fast ${array2[$i]} | grep  Execution | cut --delimiter=\  -f 3)
        #Y sumamos los datos a las medias guardadas en los arrays
        slowTime[${array1[$i]}]=$(echo "scale = 5; ${slowTime[${array1[$i]}]} +  $slow / $Niter " | bc -l)
        fastTime[${array2[$i]}]=$(echo "scale = 5; ${fastTime[${array2[$i]}]} +  $fast / $Niter " | bc -l)
#        slowTime[${array1[$i]}]+=$(echo "scale = 5; $slow / $Niter " | bc -l)
#        fastTime[${array2[$i]}]+=$(echo "scale = 5; $fast / $Niter "| bc -l)
    done
done 

for key in ${!slowTime[@]}
do
  #echo "$key ${slowTime[$key]} ${fastTime[$key]}"  
  echo "$key ${slowTime[$key]} ${fastTime[$key]}" >> $fDAT    
done

sort $fDAT -o $fDAT

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

