class Main {
    main() : Object{
        (new A).do(8)
    };
};

class A inherits IO{
    some : Int <- ~6;
    do(some : Int) : Int{
        {
            if some < 0 then
                out_string("Less\n")
            else
                out_string("More\n")
            fi;
            some;
        }
    };
};
