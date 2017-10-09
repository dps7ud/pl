rm $1--lex
rm $1-lex
./a.out $1
cool --lex $1
diff $1-lex $1--lex
