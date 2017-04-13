cool --type $1
ocaml main.ml
DIFF=$(diff $1-type X.cl-type)
if [ "$DIFF" != "" ]
then
    vimdiff $1-type X.cl-type
    echo "mine cool"
#    echo "$DIFF"
else
    echo "No diffs"
fi
