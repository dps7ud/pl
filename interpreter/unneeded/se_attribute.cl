class Main inherits IO{
    a : A <- new A;
    main() : Object{
        a.put()
    };
};

class A inherits IO{
    i : Int;
    j : Int <- {
        i <- 6;
        2;
    };
    put() : Object{
        {
            out_int(i);
            out_int(j);
            out_string("\n");
        }
    };
};
