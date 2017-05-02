class Main inherits IO {
    a: A <- new A;
    b: A <- new A;
    main() : Object{{
        b.assign(a.get());
        if a = b then
            out_string("EQUAL\n")
        else
            out_string("NEQ\n")
        fi;
    }};
};

class A{
    i: Int <- 40;
    assign(arg: Int): Object{
        i <- arg
    };
    get(): Int{i};
};
