rm ref.cl-ast
rm $1-ast
cool --lex $1
cool --parse $1 --out ref
python main.py $1-lex
DIFF=$(diff ref.cl-ast $1-ast)
if [ "$DIFF" != "" ]
then
    vimdiff ref.cl-ast $1-ast
    #echo "$DIFF"
else
    echo "No diff"
fi
