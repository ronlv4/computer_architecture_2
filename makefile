all: calc

calc: obj/calc.o
	gcc -m32 -Wall -g obj/calc.o -o bin/calc

obj/calc.o: src/calc.s
	nasm -f elf src/calc.s -o obj/calc.o

clean:
	rm -rf bin/* obj/*
