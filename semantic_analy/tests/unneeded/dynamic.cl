class Main inherits IO{
    main() : Object {
        {
            out_string("start\n");
            let obj : A <- new A in
                obj.a();
            let obj : A <- new B in
                obj.a();
            let obj : A <- new C in
                obj.a();
            let obj : A <- new D in
                obj.a();
            let obj : C <- new D in
                obj@B.a();
        }
    };
};
class A inherits IO{
    a() : Object {out_string("A\n")};
};
class B inherits A{ };
class C inherits B{ };
class D inherits C{
    a() : Object {out_string("D\n")};
};
