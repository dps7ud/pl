class Main inherits IO{
    main() : Object {
        let a : A <- new A in
            {
                a;
                out_int(a.get_a());
                out_int(a.get_b());
                out_int(a.get_c());
                out_string("exiting\n");
            }
    };
};

class A{
    c : Int <- if a < 0 then 4 else 9 fi;
    a : Int <- ~1;
    b : Int <- if a < 0 then 4 else 9 fi;
    get_a() : Int {a};
    get_b() : Int {b};
    get_c() : Int {c};
};

