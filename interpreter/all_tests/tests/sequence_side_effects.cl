class Main inherits IO{
    a : A <- new A;
    main() : Object {
        {
            out_int(a.incr());
            out_int(a.incr());
            out_int(a.incr());
            out_int(a.incr());
            out_int(a.get_a());
        }
    };
};

class A{
    a : Int <- 1; 
    incr() : Int{
         a <- a + 1
    };
    get_a() : Int {
        a
    };
};
