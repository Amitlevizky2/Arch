all: ass3

ass3: ass3.s
	nasm -g -f elf ass3.s -o ass3.o 
	gcc -m32 -Wall -g ass3.o -o ass3 

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o ass3

