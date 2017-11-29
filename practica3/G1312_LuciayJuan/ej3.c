#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include "arqo3.h"

#define ERROR 1
#define OK 0

float normal(tipo **mat1, tipo **mat2, tipo **res, int tam);
float traspuesta(tipo **mat1, tipo **mat2, tipo **res, int tam);

int main(int argc, char * argv[]){
    int tam;
    float interval;
    tipo ** mat1;
    tipo ** mat2;
    tipo ** res;
    if(argc != 3) {
        printf("Error argumentos: ./ej3 normal/traspuesta tamanio\n");
        return ERROR;
    }
    tam=atoi(argv[2]);

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
    
    if(strcmp("normal", argv[1]) == 0){
        interval = normal(mat1, mat2, res, tam);
    }else if(strcmp("traspuesta", argv[1]) == 0){
        interval = traspuesta(mat1, mat2, res, tam);
    }else{
        printf("Error argumentos: ./ej3 normal/traspuesta tamanio\n");
        return ERROR;
    }
    
    printf("%f\n", interval);

    freeMatrix(mat1);
    freeMatrix(mat2);
    freeMatrix(res);

    return OK;
}

/* Normal y traspuesta no controlan error en argumentos de entrada
 * porque estos ya han sido comprobados en main y estas funciones son
 * privadas */

float normal(tipo **mat1, tipo **mat2, tipo **res, int tam){
    int i, j, k;
    struct timeval fin, ini;
    float interval;
    gettimeofday(&ini, NULL);
    for(i = 0; i < tam; i++){
        for(j = 0; j < tam; j++){
             res[i][j]= 0;
             for(k = 0; k < tam; k++){
                res[i][j]+= mat1[i][k]*mat2[k][j];
             }
        }
    }
    gettimeofday(&fin, NULL);
    interval = ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*(1.0/1000000.0);
    return interval;
}

float traspuesta(tipo **mat1, tipo **mat2, tipo **res, int tam){
    int i, j, k;
    struct timeval fin, ini;
    float interval;
    tipo swp;
    
    gettimeofday(&ini, NULL);
    /* Primero trasponemos*/ 
    for(i = 1; i < tam; i ++){
        for(j = 0; j < i; j++){
            swp = mat2[i][j];
            mat2[i][j] = mat2[j][i];
            mat2[j][i] = swp;
        }
    }
    /*Y ahora multiplicamos*/
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
    return interval;
}

