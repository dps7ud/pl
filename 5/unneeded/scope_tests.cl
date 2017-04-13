class Main inherits IO{
    a: Int;
    b: Int;
    main() : Object{
            let a: Int <- 20, b: Int <- 30 in{
                out_int((new A).method(a, b));
                out_string("\n");
            }
    };
};

class A{
    a : Int <- ~1;
    b : Int <- 5;
    method(a: Int, b: Int): Int{
        a * b
    };
};
