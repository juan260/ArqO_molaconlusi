LIBS = 
LIB_DIR =  
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: mult_matrix clear

mult_matrix: mult_matrix.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS) 

clean:
	rm -f *.o *~ mult_matrix
	
clear:
	rm -f *.o *~
