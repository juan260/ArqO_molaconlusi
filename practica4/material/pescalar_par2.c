// ----------- Arqo P4-----------------------
// pescalar_par2
//
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "arqo4.h"

int main(int argc, char **argv)
{
	float *A=NULL, *B=NULL;
	long long k=0, tam;
	int nthreads;
	struct timeval fin,ini;
	float sum=0;
	
	if(argc != 3){
		printf("Error en los arg entrada: ./pescalar_par2.c tamanio nthreads\n");
		return -1;
	}
	
	tam = atoi(argv[1]);
	nthreads = atoi(argv[2]);
	A = generateVector(tam);
	B = generateVector(tam);
	if ( !A || !B )
	{
		printf("Error when allocationg matrix\n");
		freeVector(A);
		freeVector(B);
		return -1;
	}
	
	gettimeofday(&ini,NULL);
	/* Bloque de computo */
	sum = 0;
	omp_set_num_threads(nthreads);
	#pragma omp parallel for reduction(+:sum)
	for(k=0;k<tam;k++)
	{
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	//printf("Resultado: %f\n",sum);
	printf("%f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
