class Main inherits IO{
    j : Int <- 9;
    i : Int <- 2;
    do() : Int{i <- i+1};
    main() : Object{
        {
            i <- do();
            out_int(i);
            j <- do();
            out_int(j);
        }
    };
};
