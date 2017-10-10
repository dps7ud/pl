class Main{
    a : Int;
    main() : Object {
        let a : A <- new A in 
            a.out(a)
    };
};

class A inherits IO{
    out(arg : Object) : Object {
        case arg of
            s : String => out_string(s.concat("\n"));
            i : Int => {out_int(i); out_string("\n");};
            o : Object => out_string("Unsupported type: ".concat(o.type_name()).concat("\n"));
        esac
    };
};
