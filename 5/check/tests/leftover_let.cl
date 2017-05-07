class Main inherits IO{
    a : Int;
    out(o: Object) : Object{
        case o of
            z: Int => out_string("Int\n");
            c: A => out_string("A\n");
            x: Object => out_string("Other\n");
        esac
    };
    main() : Object {
        {
            let a : A <- new A in 
                true;
            out(a);
        }
    };
};

class A{};
