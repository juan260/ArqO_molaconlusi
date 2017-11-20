#!/usr/bin/env python
#Script asociado al ejercicio 1
import subprocess
#OJO HALLAR P
P = 1
repeticiones=20
for muda in range(repeticiones):
	for N in range(5): #range(10000+1024*P, 10000+1024*(P+1), 64):
		#Ejecutamos un comando qe devuelve unicamente los tiempos de ejecucion, parseamos la salida y la guardamos en
		#un diccionario
		a=subprocess.call("./slow 10 | grep Execution | cut --delimiter=\  -f 3", shell=True)
		#slowTimes[N]=slowTimes[N]+()/repeticiones
		#print a

	
