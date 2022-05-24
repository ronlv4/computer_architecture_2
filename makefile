all: clean calc run

calc: obj/calc.o
	gcc -m32 -Wall -g -no-pie obj/calc.o -o bin/calc

obj/calc.o: src/calc.s
	nasm -f elf -g src/calc.s -o obj/calc.o

clean:
	rm -rf bin/* obj/*

run:
	./bin/calc A
