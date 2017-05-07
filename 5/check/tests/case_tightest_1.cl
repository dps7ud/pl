class Main{
    main() : Object{
        {
            aef(new A);
            aef(new E);
            aef(new F);
        }
    };
    aef(i: Object): Object{
        case i of
            a: A => a.print_new();
            e: E => e.print_new();
            f: F => f.print_new();
        esac
    };
};

class A inherits IO{
    print_new() : SELF_TYPE{
        {
            out_string(type_name());
            out_string("\n");
            new SELF_TYPE;
        }
    };
};

class B inherits A{};
class C inherits B{};
class D inherits B{};

class E inherits A{};
class F inherits E{};
class G inherits E{};
