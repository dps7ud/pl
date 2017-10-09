class Main {
    main() : Object{
        case c of
            s : SELF_TYPE => new SELF_TYPE;
        esac
    };
    c : Int;
};

class B inherits A{
};
class A{
    a : Int;
    b() : Int {
        a
    };
};
class D inherits B{};
class E inherits B{};
