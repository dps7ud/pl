ocamlopt main.ml
#for loop
cool --type $1
./a.out $1-type > my_out.txt
cool $1 > cool_out.txt
printf "\n"
DIFF=$(diff cool_out.txt my_out.txt)
if [ "$DIFF" != "" ]
then
    #vimdiff $1-type X.cl-type
    printf "$DIFF"
    printf "\n"
else
    rm cool_out.txt
    rm my_out.txt
    rm $1-type
    printf "Passed $1\n"
fi
rm main.cmx main.o main.cmi a.out
