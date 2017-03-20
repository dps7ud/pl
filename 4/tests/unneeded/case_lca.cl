class Main inherits IO{
    b : C <-
        case 4 of
            e : E => (new E);
            f : F => (new F);
        esac;
    main() : Object {
        8
    };
};

class A inherits IO{};
class B inherits A{};
class C inherits A{};
class E inherits B{};
class F inherits B{};
