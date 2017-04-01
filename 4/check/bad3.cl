class Main {
    main() : Object{
        case c of
            s : SELF_TYPE => new SELF_TYPE;
        esac
    };
    c : Int;
};

class SELF_TYPE{};
class B inherits A{ };
class A{ a : Int; b() : Int { a }; };
