// ----------- Arqo P4-----------------------
// pescalar_serie
//

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include "arqo4.h"

int main(int argc, char **argv)
{
	float *A=NULL, *B=NULL;
	long long k=0, tam;
	struct timeval fin,ini;
	float sum=0;
    /*struct timeval inini;
	gettimeofday(&inini,NULL);*/

    if(argc != 2){
        printf("Arg incorrecto: ./pescalar_serie tamanio\n");
        return -1;
    }

    tam = atoi(argv[1]);
	
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
	for(k=0;k<tam;k++)
	{
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	//printf("Resultado: %f\n",sum);
	//printf("%f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(inini.tv_sec*1000000+inini.tv_usec))*1.0/1000000.0);
	printf("%f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
