--class A{
--    a : Int <- (new B).g();
--    f() : String {a};
--};
--class B{
--    b : String <- (new A).f();
--    g() : Int {b};
--};
class Main inherits IO{
    main() : Object{
        {
            let c : C <- (new C) in
                c.put();
            let a : C <- (new D) in
                a.put();
        }
    };
};

class C inherits IO{
    a : SELF_TYPE <- f();--(new D);
    f() : SELF_TYPE{
        self
    };
    put() : Object { 
        {
            out_string(a.type_name());
            out_string("\n");
        }
    };
};
class D inherits C{
--    b : SELF_TYPE <- (new D);
--    f() : Object{
--        out_string(b.type_name())
--    };
--    
    put() : Object { 
        {
            out_string(a.type_name());
            out_string("\n");
            out_int(2);
            out_string("\n");
        }
    };
};
