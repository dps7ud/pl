class Main inherits IO{
    main() : Object {
        (new A).put()
    };
};

class A inherits IO{
    b : Int <- if a < 1 then 100 else 200 fi;
    a : Int <- 3;
    put() : Object{
        {
        out_int(a);
        out_int(b);
        }
    };
};
