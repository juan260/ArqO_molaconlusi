#/bin/bash

ini=50000000
end=850000000
paso=80000000
niter=5
fDat=pescalar.dat
fImg=pescalar.png

array=($(seq $ini $paso $end))

make clean
make

> $fDat
#Esto cambia el formato float: de 1,23 a 1.23 para que la salida
#de su programa sea considerada float
export LC_NUMERIC="en_US.UTF-8"
make clean
make
for item in ${array[@]}
do
    echo "tam = $item"
    uno=0;dos=0;tres=0;cuatro=0;
    for i in $(seq 0 1 $niter)
    do
        echo "    iter = $i"
        tmp=$(./pescalar_serie $item)
        uno=$(echo "scale = 5; $uno + $tmp / $niter " | bc -l)
        tmp=$(./pescalar_par2 $item 2)
        dos=$(echo "scale = 5; $dos+ $tmp / $niter " | bc -l)
        tmp=$(./pescalar_par2 $item 3)
        tres=$(echo "scale = 5; $tres+ $tmp / $niter " | bc -l)        
        tmp=$(./pescalar_par2 $item 4)
        cuatro=$(echo "scale = 5; $cuatro+ $tmp / $niter " | bc -l)        
    done    
    printf "%d \t%f \t%f \t %f \t%f \n" $item $uno $dos $tres $cuatro >> $fDat

done

gnuplot << END_GNUPLOT
set title "Producto escalar segun tamanios e hilos"
set ylabel "Tiempo - segundos"
set xlabel "Tamanio"
set key right bottom
set grid
set term png
set output "$fImg"
plot "$fDat" using 1:2 with lines lw 2 title "1 thread", \
    "$fDat" using 1:3 with lines lw 2 title "2 threads", \
    "$fDat" using 1:4 with lines lw 2 title "3 threads", \
    "$fDat" using 1:5 with lines lw 2 title "4 threads" 
replot
quit
END_GNUPLOT

./aceleracion.sh $fDat
