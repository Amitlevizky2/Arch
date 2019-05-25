all: calc

calc: calc.s
	nasm -g -f elf calc.s -o calc.o 
	gcc -m32 -Wall -g calc.o -o calc 

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o calc

