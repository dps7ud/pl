class Main inherits IO{
    a : A <- new A;
    main() : Object {{
        case a.iincr() of
            s : String => new String;
            i : Int => a.incr();
        esac;
        out_int(a.incr());
    }};
};

class A{
    a : Int <- 1; 
    incr() : Int{
        a <- a + 1
    };
    iincr(): Int{
        a <- a + 2
    };
};
