#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: ass1

# Tool invocations
# Executable "ass1" depends on the files main_task1Assignment1.o and asm_task1Assignment1.o.
ass1: main_task1Assignment1.o asm_task1Assignment1.o
	gcc -m32 -g -Wall -o ass1 main_task1Assignment1.o asm_task1Assignment1.o

# Depends on the source and header files
main_task1Assignment1.o: main_task1Assignment1.c 
	gcc -g -Wall -m32  -c -o main_task1Assignment1.o main_task1Assignment1.c
asm_task1Assignment1.o: asm_task1Assignment1.s
	nasm -g -f elf -w+all -o asm_task1Assignment1.o asm_task1Assignment1.s
	

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o ass1
