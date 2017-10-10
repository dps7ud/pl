ocamlopt -c a_typedefs.ml
ocamlopt -c deserialize.ml
ocamlopt -c main.ml
ocamlopt -o interp a_typedefs.cmx deserialize.cmx main.cmx
if [ -e interp_errors.txt ]; then
    rm interp_errors.txt
fi
# Default mode: try everything in directory

#Select test suite by manually editing
# TEST_DIR=./trouble
TEST_DIR=./all_tests/tests
if [ $# -eq 0 ]; then
    for filename in $TEST_DIR/*.cl; do
        cool --type $filename
        #printf "$filename\n"
        if [ -e "$filename-input" ]; then
            ./interp $filename-type < $filename-input 1> my_out.txt 2> one_error.txt
            cool $filename < $filename-input > cool_out.txt
            printf "Using input file:" >> one_error.txt
            printf "$filename-input" >> one_error.txt
            printf "\n" >> one_error.txt
        else
            ./interp $filename-type 1> my_out.txt 2> one_error.txt
            cool $filename > cool_out.txt
        fi
        DIFF=$(diff cool_out.txt my_out.txt)
        if [ "$DIFF" != "" ]
        then
            ERR=$(cat one_error.txt)
            if [ "$ERR" != "" ]
            then
                printf "ERROR in\n" >> interp_errors.txt
                printf "$filename\n" >> interp_errors.txt
                cat one_error.txt >> interp_errors.txt
                printf "E"
            else
                printf "FAILURE in\n" >> interp_errors.txt
                printf "$filename\n" >> interp_errors.txt
                printf "F"
            fi
            echo "$DIFF" >> interp_errors.txt
            printf "\n======================================================\n" \
            >> interp_errors.txt


            #vimdiff $1-type X.cl-type
            #printf "$filename:FAILED\n"
        else
            printf "."
        fi
        rm cool_out.txt
        rm one_error.txt
        rm my_out.txt
    done
    printf "\n"
    if [ -e interp_errors.txt ]
    then
        cat interp_errors.txt
    else
        printf "\nPassed all tests\n"
    fi
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
