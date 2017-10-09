class Main{
    main() : Object { 
        case closed of
            d : D => new D;
            e : E => new E;
            f : F => new F;
            g : G => new G;
        esac
    };
    closed : G;
    geta() : A{new A};
    f : A <- geta();
    a : SELF_TYPE <- new SELF_TYPE;
    g : A <- new A;
};
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
