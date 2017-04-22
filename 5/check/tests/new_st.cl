class Main inherits IO{
    a: A <- new A;
    main(): Object{{
        a.incr();
        a.incr();
        a.incr();
        out_int(a.get_i());
        out_string("\n");
        a.test();
        out_int(a.get_a().get_i());
        out_string("\n");
        a.get_a().incr();
        a.get_a().incr();
        a.get_a().incr();
        a.get_a().incr();
        out_int(a.get_a().get_i());
        out_string("\n");
    }};
};

class A{
    i: Int;
    st: A;
    get_i(): Int{i};
    get_a(): A{st};
    incr(): Int{i <- i + 1};
    test(): Object{
        st <- new SELF_TYPE
    };
};  
