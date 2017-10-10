class Main inherits IO{
    main() : Object{
        out_int((new A).alter().get())
    };
};

class A{
    i : Int;
    get() : Int {i};
    alter() : SELF_TYPE{
        {
        i <- i - 1;
        self;
        }
    };
};
