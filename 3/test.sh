rm ref.cl-ast
rm $1-ast
cool --lex $1
cool --parse $1 --out ref
python main.py $1-lex
echo "theirs, mine"
diff ref.cl-ast $1-ast
