make
./a.out $1
cool --lex $1
diff $1-lex $1-lex1
