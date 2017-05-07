class Main inherits IO{
    main(): Object{
        let i: Int <- 0 in
            do(i)
    };
    do(j: Int): Int{
        {
        out_int(j);
        out_string("\n");
        do(j + 1);
        }
    };
};
