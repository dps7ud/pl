class Main inherits IO{
    main(): Object{
        {
            method(new C);
            method(new B);
        }
    };
    method(e: Object): Main{
        case e of
            c: C => {new C; out_string("C");};
            b: B => {new B; out_string("B");};
        esac
    };
};

class Root inherits IO{};
class A inherits Root{};
class B inherits A{};
class C inherits A{};
