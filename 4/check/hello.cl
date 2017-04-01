class Main inherits IO{
    main() : Object { 
        9
    };
};
(*
    i : Object <- printh();

    printh() : Int {  0};
};
class A{
    a : Int;
    b() : Int {
        a
    };
};
class B inherits A{
    b() : Int {
        1
    };
--    c : Int <- b@A();
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
