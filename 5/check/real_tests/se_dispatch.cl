class Main{
    a : A <- (new A);
    main(): Object{
        {
            a.put();
            a.alter().put();
            a.alter().put_2(a.get());
            a.put_2( a.alter().get());
        }
    };
};

-- We desire to differentiate if the dispatch 
--  expr or argumets are evaluated first


class A inherits IO{
    i : Int;
    alter() : SELF_TYPE{
        {
            i <- i + 10;
            self;
        }
    };
    get() : Int {
        i <- i + 15
    };
    put() : Object{
        {
            out_int(i);
            out_string("\n");
        }
    };
    put_2(j: Int) : Object{
        {
            out_int(j);
            out_string("\n");
        }
    };
};
