if [[ $1 == "-d" ]]; then
    rm X.cl-type
    rm *-ast
    rm *-type
    cool --parse $2
    cool --class-map --out X $2
    node --inspect --debug-brk main.js $2-ast
else
    rm X.cl-type
    rm *-ast
    rm *-type
    cool --parse $1
    cool --class-map --out X $1
    node main.js $1-ast
    DIFF=$(diff $1-type X.cl-type)
    if [ "$DIFF" != "" ]
    then
        vimdiff $1-type X.cl-type
#        echo "mine cool"
#        echo "$DIFF"
    else
        echo "No diffs"
    fi
fi
