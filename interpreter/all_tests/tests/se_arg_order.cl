class Main inherits IO{
    a : Actor <- new Actor;
    s : Sentinal <- new Sentinal;
    main(): Object{
        {
            s.check();
            a.method(s.one(), s.two());
        }
    };
};

class Actor inherits IO{
    method(x: Int, y: Int) : Object{
        {
            out_int(x);
            out_int(y);
        }
    };
};

class Sentinal inherits IO{
    i : Int <- 11;
    j : Int <- 99;
    check() : Object{
        {
            out_int(i);
            out_int(j);
        }
    };
    one() : Int{
        i <- j
    };
    two() : Int{
        j <- i
    };
};
