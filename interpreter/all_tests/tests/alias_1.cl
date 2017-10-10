class Main inherits IO{
    a: Wrap <- new Wrap;
    b: Wrap <- new Wrap;
    c: Wrap <- new Wrap;

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
        do(a,b);
        do(c,c);
    }
    };
};

class Wrap{
    i: Int;
    get() : Int {i};
    set(j: Int) : Int{i<-j};
    incr(): Int{i<-i+1};
};
