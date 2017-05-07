class Main inherits IO{
    a : A <- new A;
    main() : Object {
        if a.incr() then
            out_int(a.get())
        else
            out_int(a.get() + 200)
        fi
    };
};

class A{
    a : Int <- 1; 
    incr() : Bool{
        {
            a <- a - 10;
            a < 3;
        }
    };
    get() : Int {a};
};
