class Main inherits IO{
    a: A <- new A;
    k: Int;
    main() : Object{
        while a.incr_check(10) loop{
            out_int(a.get());
            out_string("\n");
            k <- k + 1;
            if 100 < k then
                abort()
            else
                k
            fi;
        } pool
    };
};

class A{
    i: Int;
    get() : Int {i};
    incr_check(j: Int): Bool{
    {
        i <- i + 1;
        i < j;
    }
    };
};
