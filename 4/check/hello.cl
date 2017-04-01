class Main{
    main() : Object { 
        9
    };
    geta() : A{new A};
    f : A <- geta();
    g : A <- new A;
};
class A{};
(*
class B inherits A{
    b() : Int {
        1
    };
--    c : Int <- b@A();
};
class A{
    a : Int;
    b() : Int {
        a
    };
};
class D inherits B{};
class E inherits B{};

class C inherits A{
};
class F inherits C{};
class G inherits C{};
class A{
    a : Int <- 4 + 67;
    a() : Int {5};
};
class C inherits B{
    c() : Int {4};
};
*)
