class Main inherits IO{
    a : A <- (new A);
    b : B <- (new B);
    c : C <- (new C);
    d : D <- (new D);
    main() : Object {
        {
            a_method(a);
            b_method(a);
            c_method(a);
            d_method(a);
            x_method(a);

            a_method(b);
            b_method(b);
            c_method(b);
            d_method(b);
            x_method(b);

            a_method(c);
            b_method(c);
            c_method(c);
            d_method(c);
            x_method(c);

            a_method(d);
            b_method(d);
            c_method(d);
            d_method(d);
            x_method(d);
        }
    };
    x_method (var : A) : Object{
        case var of
            c : C => out_string("C");
            b : B => out_string("B");
            a : A => out_string("A");
            o : Object => out_string("O");
        esac
    };
    a_method (var : A) : Object{
        case var of
            d : D => out_string("D");
            c : C => out_string("C");
            b : B => out_string("B");
            a : A => out_string("A");
            o : Object => out_string("O");
        esac
    };
    b_method (var : A) : Object{
        case var of
            b : B => out_string("B");
            c : C => out_string("C");
            d : D => out_string("D");
            o : Object => out_string("O");
        esac
    };
    c_method (var : A) : Object{
        case var of
            c : C => out_string("C");
            d : D => out_string("D");
            o : Object => out_string("O");
        esac
    };
    d_method (var : A) : Object{
        case var of
            b : B => out_string("B");
            d : D => out_string("D");
            o : Object => out_string("O");
        esac
    };
};

class A{};
class B inherits A{};
class C inherits B{};
class D inherits A{};
