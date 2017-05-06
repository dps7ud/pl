class Main inherits IO{
    a: A <- new A;
    main(): Object{{
        let x: Int <- a.do(), y: Int <- a.do() in
        {
            out_int(a.get());
            out_string("\n");
            a.do();
        };
        out_int(a.get());
        out_string("\n");
    }};
};

class A{
    i: Int <- 22;
    do() : Int {
        i <- i * 3
    };
    get(): Int {i};
};
