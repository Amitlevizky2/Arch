# All Targets
all: ass3

ass3: target.s drone.s printer.s scheduler.s ass3.s
	nasm -f elf target.s -g -o target.o 
	nasm -f elf drone.s -g -o drone.o 
	nasm -f elf scheduler.s -g -o scheduler.o 
	nasm -f elf printer.s -g -o printer.o 
	nasm -f elf ass3.s -g -o ass3.o 
	gcc -m32 -Wall -g ass3.o target.o drone.o scheduler.o printer.o  -o ass3 


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o ass3