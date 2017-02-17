all: a.out

lex.yy.c: broken.lex
	flex broken.lex

a.out: lex.yy.c
	gcc lex.yy.c -lfl
