class Main inherits IO{
    b : B;
    o : Object;
    main() : Object {
        case 4 of
            a : A => new A;
            b : B => new B;
        esac
    };
};

class A inherits IO{};
class B inherits A{};
