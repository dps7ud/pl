ocamlopt -c typedefs.ml
ocamlopt -c deserialize.ml
ocamlopt -c main.ml
ocamlopt -o interp typedefs.cmx deserialize.cmx main.cmx
#for loop
if [ $# -eq 0 ]; then
    for filename in ./tests/*.cl; do
#    for filename in ./real_tests/*.cl; do
        cool --type $filename
        ./interp $filename-type > my_out.txt
        cool $filename > cool_out.txt
        printf "\n"
        DIFF=$(diff cool_out.txt my_out.txt)
        if [ "$DIFF" != "" ]
        then
            #vimdiff $1-type X.cl-type
            printf "$filename:FAILED\n"
            printf "$DIFF"
            printf "\n"
        else
            rm cool_out.txt
            rm my_out.txt
            rm $filename-type
            printf "Passed $filename"
            printf "\n"
        fi
    done
else
    cool --type $1
    ./interp $1-type > my_out.txt
    cool $1 > cool_out.txt
    printf "\n"
    DIFF=$(diff cool_out.txt my_out.txt)
    if [ "$DIFF" != "" ]
    then
        #vimdiff $1-type X.cl-type
        printf "\n$1:FAILED\n"
        printf "$DIFF"
        printf "\n"
    else
        rm cool_out.txt
        rm my_out.txt
        rm $1-type
        printf "Passed $1"
        printf "\n"
    fi
fi
rm *.cmx *.o *.cmi interp
