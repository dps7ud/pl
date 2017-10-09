class Main{
    a : Actor <- new Actor;
    main(): Object{
        {
            a.put();
            a.method();
            a.put();
        }
    };
};

class Actor inherits IO{
    i : Int;
    put() : Object{
        out_int(i)
    };
    method() : Object{
        i <- i + 10
    };
};
