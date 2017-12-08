#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include <omp.h>
#include "arqo3.h"

#define ERROR 1
#define OK 0

float traspuesta(tipo **mat1, tipo **mat2, tipo **res, int tam, int threads, int par);
void serie(int tam, tipo **mat1, tipo **mat2, tipo **res);
void par1(int tam, tipo **mat1, tipo **mat2, tipo **res);

int main(int argc, char * argv[]){
    int tam, threads, par;
    int i, j, k;
    struct timeval fin, ini;
    tipo swp;
    float interval;
    tipo ** mat1;
    tipo ** mat2;
    tipo ** res;
    if(argc != 4) {
        printf("Error argumentos: ./mult_matrix_par1 tamanio "
        "numero_de_threads bucle_a_paralelizar\n"
        "Donde bucle_a_paralelizar puede tomar los valores:\n"
        "\t-0: ejecucion en serie\n\t-1: paridad del bucle 1\n\t"
        "-2: paridad del bucle 2\n\t-3: paridad en el bucle 3\n");
        return ERROR;
    }

    tam=atoi(argv[1]);
    threads=atoi(argv[2]);
    par=atoi(argv[3]);
    if(tam<1||threads<1||par<0||par>3){
        printf("Error, valores incorrectos\n");

    }

    mat1=generateMatrix(tam);
    mat2=generateMatrix(tam);
    res=generateEmptyMatrix(tam);
    if( !mat1 || !mat2 || !res ){
        if(mat1) freeMatrix(mat1);
        if(mat2) freeMatrix(mat2);
        if(res) freeMatrix(res);
        printf("Error en la reserva de matrices\n");
        return ERROR;
    }
    
    
    gettimeofday(&ini, NULL);
    /* Primero trasponemos*/ 

    for(i = 1; i < tam; i ++){
        for(j = 0; j < i; j++){
            swp = mat2[i][j];
            mat2[i][j] = mat2[j][i];
            mat2[j][i] = swp;
        }
    }

            
	omp_set_num_threads(threads);
    #pragma omp parallel for private(j,k)   
            for(i = 0; i < tam; i++){
                for(j = 0; j < tam; j++){
                    res[i][j]= 0;
                    for(k = 0; k < tam; k++){
                        res[i][j]+= mat1[i][k]*mat2[j][k];
                    }
                }
            }   



    gettimeofday(&fin, NULL);
    interval = ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*(1.0/1000000.0);
    
    printf("\n");
    for(i=0;i<tam;i++){
        for(j=0;j<tam;j++){
            printf("%d ", (int)(res[i][j]));
        }
        printf("\n");
    }
    printf("%f\n", interval);

    freeMatrix(mat1);
    freeMatrix(mat2);
    freeMatrix(res);

    return OK;
}

/* No controlamos aquí error en argumentos de entrada
 * porque estos ya han sido comprobados en main y estas funciones son
 * privadas */

float traspuesta(tipo **mat1, tipo **mat2, tipo **res, int tam, int threads, int par){

    

    return 0.0;
}


void serie(int tam, tipo **mat1, tipo **mat2, tipo **res){
    int i, j, k;
    
    for(i = 0; i < tam; i++){
        for(j = 0; j < tam; j++){
             res[i][j]= 0;
             for(k = 0; k < tam; k++){
                res[i][j]+= mat1[i][k]*mat2[j][k];
             }
        }
    }   

}


void par1(int tam, tipo **mat1, tipo **mat2, tipo **res){
    int i, j, k;
    
	#pragma omp parallel for
    for(i = 0; i < tam; i++){
        for(j = 0; j < tam; j++){
             res[i][j]= 0;
             for(k = 0; k < tam; k++){
                res[i][j]+= mat1[i][k]*mat2[j][k];
             }
        }
    }   

}
