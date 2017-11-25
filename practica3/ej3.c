#include <stdio.h>
#include <stdlib.h>
#include "arqo3.h"
#define ERROR 1
#define OK 0

int main(int argc, char * argv[]){
    int N;
    tipo ** matriz1;
    tipo ** matriz2;
    tipo ** matrizRes;
    if(argc != 2) {
        printf("Error, debe recibir un unico argumento que\n"
            "sea el tamaño de la matriz\n");
        return ERROR;
    }
    N=atoi(argv[1]);
    matriz1=generateMatrix(N);
    matriz2=generateMatrix(N);
    matrizRes=generateEmprtyMatrix(N);


    freeMatrix(matriz1);
    freeMatrix(matriz2);
    freeMatrix(matrizRes);

    return OK;
}

