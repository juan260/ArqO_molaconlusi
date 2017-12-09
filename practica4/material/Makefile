LIBS = 
LIB_DIR =  
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: omp1 omp2 pescalar_serie pescalar_par1 pescalar_par2 mult_matrix pi_par1 pi_par2 pi_par3 pi_par4 clear

omp1: omp1.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

omp2: omp2.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_serie: pescalar_serie.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par1: pescalar_par1.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par2: pescalar_par2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par1: pi_par1.c 
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par2: pi_par2.c 
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par3: pi_par3.c 
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par4: pi_par4.c 
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

mult_matrix: mult_matrix.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS) 

pi_par2: pi_par2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par3: pi_par3.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par1: pi_par1.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par4: pi_par4.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par5: pi_par5.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par6: pi_par6.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par7: pi_par7.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ omp1 omp2 pescalar_serie mult_matrix pescalar_par1 pescalar_par2 pi_par1 pi_par2 pi_par3 pi_par4
	
clear:
	rm -f *.o *~
