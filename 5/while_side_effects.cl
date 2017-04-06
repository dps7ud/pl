class Main inherits IO{
    a : A <- new A;
    main() : Object {
        while a.incr() loop
            out_int(a.get())
        pool
    };
};

class A{
    a : Int <- 1; 
    incr() : Bool{
         {
             a <- a + 1;
             a < 10;
         }
    };
    get() : Int {a};
};
