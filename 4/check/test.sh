if [[ $1 == "-d" ]]; then
    rm X.cl-type
    rm $2-ast
    rm $2-type
    cool --parse $2
    cool --class-map --out X $2
    node --inspect --debug-brk io.js $2-ast
else
    rm X.cl-type
    rm $1-ast
    rm $1-type
    cool --parse $1
    cool --class-map --out X $1
    node io.js $1-ast
    DIFF=$(diff $1-type X.cl-type)
    if [ "$DIFF" != "" ]
    then
        echo "mine cool"
        echo "$DIFF"
    else
        echo "No diffs"
    fi
fi
