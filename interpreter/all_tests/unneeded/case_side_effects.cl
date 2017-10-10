class Main {
    a : A <- new A;
    main() : Object {
        case a.incr() of
            s : String => new String;
            i : Int => a.incr();
        esac
    };
};

class A{
    a : Int <- 1; 
    incr() : Int{
        a <- a + 1
    };
};
