#!/bin/bash


echo "Calculando tiempos"


for i in $(seq $1); do
 for j in $(seq 0 3); do
  matrix1[$i$j]=$(./mult_matrix $2 $i $j)
  #echo $matrix1[$i$j]
  matrix2[$i$j]=$(echo "${matrix1[10]}/${matrix1[$i$j]}" | bc -l| head -c 8)
 done
done



echo -e "\nTiempos de ejecución para tamaño $2:"
echo -e "\nVersión\t1 Hilo\t\t2 Hilos\t\t3 Hilos\t\t4 Hilos\n"

echo -e "Serie:\t${matrix1[10]}\t${matrix1[20]}\t${matrix1[30]}\t${matrix1[40]}\n"
echo -e "Par 1:\t${matrix1[11]}\t${matrix1[21]}\t${matrix1[31]}\t${matrix1[41]}\n"
echo -e "Par 2:\t${matrix1[12]}\t${matrix1[22]}\t${matrix1[32]}\t${matrix1[42]}\n"
echo -e "Par 3:\t${matrix1[13]}\t${matrix1[23]}\t${matrix1[33]}\t${matrix1[43]}\n"

echo -e "\nAceleracion (speedup) con respecto a la version serie para tamaño $2"
echo -e "\nVersion\t1 Hilo\t\t2 Hilos\t\t3 Hilos\t\t4 Hilos\n"

echo -e "Serie:\t${matrix2[10]}\t${matrix2[20]}\t${matrix2[30]}\t${matrix2[40]}\n"
echo -e "Par 1:\t${matrix2[11]}\t${matrix2[21]}\t${matrix2[31]}\t${matrix2[41]}\n"
echo -e "Par 2:\t${matrix2[12]}\t${matrix2[22]}\t${matrix2[32]}\t${matrix2[42]}\n"
echo -e "Par 3:\t${matrix2[13]}\t${matrix2[23]}\t${matrix2[33]}\t${matrix2[43]}\n"
