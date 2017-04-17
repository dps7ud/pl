ocamlopt main.ml
#for loop
for filename in ./tests/*.cl; do
    cool --type $filename
    ./a.out $filename-type > my_out.txt
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
rm main.cmx main.o main.cmi a.out
