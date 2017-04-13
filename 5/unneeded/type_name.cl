class Main inherits IO{
    a : A <- new A;
    b : B <- new B;
    c : C <- new C;
    d : D <- new D;

    e : A <- new B;
    f : A <- new C;
    g : A <- new D;

    h : C <- new C;
    i : C <- new D;
    main() : Object{
        {
            out_string(a.type_name());
            out_string(b.type_name());
            out_string(c.type_name());
            out_string(d.type_name());

            out_string(e.type_name());
            out_string(f.type_name());
            out_string(g.type_name());

            out_string(h.type_name());
            out_string(i.type_name());

            out_string("\n");
        }
    };
};

class A{};
class B inherits A{};
class C inherits A{};
class D inherits C{};
