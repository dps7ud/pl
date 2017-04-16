class Main inherits IO{
    a : String <- "H";
    main() : Object{
    {
        let obj : A <- new A in
            out_int(obj.f());
        out_string("\n");
    }
    };
};

class A{
    a : Int <- 9;
    f() : Int {a};
};
