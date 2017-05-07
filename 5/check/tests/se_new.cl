class Main inherits IO{
    a : A <- new A;
    main() : Object{
        {
            a.put();
            a <- a.new_A();
            a.put();
            a <- new A;
            a.put();
        }
    };
};

class A inherits IO{
    i : Int;
    j : Int;
    set(x: Int, y: Int) : Object{
        {
            i <- x;
            j <- y;
        }
    };
    put() : Object{
        {
            out_int(i);
            out_int(j);
            out_string("\n");
        }
    };
    new_A() : A{
        let val : A <- new A in
            {
                val.set(3, 9);
                val;
            }
    };
};
