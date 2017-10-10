class Main inherits IO{
    i: Int <- 0;
    main() : Object{
        out_int(do(4, 10))
    };
    do(a: Int, b: Int): Int {
        if a = 1 then
            b
        else
            do(a - 1, b) +b
        fi
    };
};
