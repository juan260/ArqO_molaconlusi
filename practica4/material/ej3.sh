#!/bin/bash
P=8
NPaso=64
NInicio=$((2048+$P))
NFinal=$(($NInicio+2048))
tmpFile=ej3.tmp
MAXHILOS=4
tamTabla1=1000
bestHilos=4
bestBucle=3
fPNGt=ej2_time.png
fPNGs=ej2_speedup.png
make clean
make 

#BORRAR
#NPaso=256
#tamTabla1=10

rm -f $tmpFile $fPNGt $fPNGs
touch $tmpFile

./tablaEj2.sh $MAXHILOS $tamTabla1

tamTabla1=$(($tamTabla1*6))

./tablaEj2.sh $MAXHILOS $tamTabla1

echo "Generando graficas..."
for i in $(seq $NInicio $NPaso $NFinal); do
    arraySerie[i]=$(./mult_matrix $i 1 0)
done
for i in $(seq $NInicio $NPaso $NFinal); do
    best=$(./mult_matrix $i $bestHilos $bestBucle)
    echo -e "$i\t${arraySerie[$i]}\t$best\t$(echo "${arraySerie[$i]}/$best" | bc -l)" >> $tmpFile
done

gnuplot << END_GNUPLOT
set title "Matrix multiplication time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGt"
plot "$tmpFile" using 1:2 with lines lw 2 title "Serie", \
     "$tmpFile" using 1:3 with lines lw 2 title "$bestHilos hilos par $bestBucle"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Matrix multiplication speedup"
set ylabel "Speedup"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGs"
plot "$tmpFile" using 1:4 with lines lw 2 title "Speedup"
replot
quit
END_GNUPLOT

