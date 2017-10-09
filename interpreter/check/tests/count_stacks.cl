class Main inherits IO{
    i : Int <- 0;
    main(): Object{
        do(i)
    };
    do(j: Int): Int{
        {
        out_int(j);
        do(j + 1);
        }
    };
};
