all: a.out

main.c: try.lex
	flex -o main.c try.lex 
a.out: main.c
	gcc -Wall *.c
