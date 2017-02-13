all: a.out

lex.yy.c: try.lex
	flex try.lex

a.out: lex.yy.c
	gcc lex.yy.c -lfl
