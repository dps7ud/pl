class Main inherits IO{
    a: A <- new A;
    main(): Object {
        let dup: A <- a.copy() in
            if a = dup then
                out_string("EQ\n")
            else
                out_string("NEQ\n")
            fi
    };
};

class A{
    i: Int <- 4;
    s: String <- "Hello";
};
