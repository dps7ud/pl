class Main inherits IO{
    a: Wrap <- new Child;
    b: Wrap <- new Child;
    c: Wrap <- new Child;

    do(x: Wrap, y: Wrap) : Object{
        {
        out_int(x.get());
        out_string(" ");
        out_int(y.get());
        out_string(" ");
        x.incr();
        out_int(x.get());
        out_string(" ");
        out_int(y.get());
        out_string("\n");
        }
    };

    main(): Object{
    {
        a.set(10);
        b.set(40);
        c.set(70);
        do(a.incr(),b.incr());
        do(c.incr(),c.incr());
    }
    };
};

class Wrap{
    i: Int;
    get() : Int {i};
    set(j: Int) : Int{i<-j};
    incr(): SELF_TYPE{{i<-i+1;self;}};
};

class Child inherits Wrap{};
