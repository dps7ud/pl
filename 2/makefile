all: a.out

main.c: pa2.lex
	flex -o main.c pa2.lex 
a.out: main.c
	gcc -Wall *.c
