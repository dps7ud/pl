class Main inherits IO{
    a: A <- new A;
    b: A <- a;
    main(): Object{
        if a = b then
            out_string("EQUAL\n")
        else
            out_string("NEQ\n")
        fi
    };
};

class A{};
