
fInput=$1
fDat="acc.dat"
fImg="acc.png"

awk 'BEGIN{ FS="\t";}
{
    printf "%d %f %f %f\n", $1, $2/$3, $2/$4, $2/$5;
}
END{}' $fInput > $fDat

gnuplot << END_GNUPLOT
set title "Aceleración producto escalar segun num hilos"
set ylabel "Aceleracion"
set xlabel "Tamanio"
set key right bottom
set grid
set term png
set output "$fImg"
plot "$fDat" using 1:2 with lines lw 2 title "2 thr/1 thr", \
    "$fDat" using 1:3 with lines lw 2 title "3 thr/1 thr", \
    "$fDat" using 1:4 with lines lw 2 title "4 thr/1 thr"
replot
quit
END_GNUPLOT



