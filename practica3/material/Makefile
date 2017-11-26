LIBS = 
LIB_DIR =  
FLAGS = -g -Wall -D_GNU_SOURCE -O3

.PHONY: clean all

all: fast slow ej3

fast: fast.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

slow: slow.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

ej3: ej3.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ fast slow ej3
