class Main inherits IO{
    a : A <- new A;
    main(): Object{
        { 
            a.one(a.two());
            if a.get() then
                out_string("two last")
            else
                out_string("one last")
            fi;
            out_string("\n");
            a.one(9);
            a.two();
            if a.get() then
                out_string("two last")
            else
                out_string("one last")
            fi;
            out_string("\n");
            a.two();
            a.one(9);
            if a.get() then
                out_string("two last")
            else
                out_string("one last")
            fi;
            out_string("\n");
        }
    };
};

class A{
    boo : Bool;
    get() : Bool{ boo};
    one(arg: Object) :Object{ boo <- false};
    two() :Object{ boo <- true};
};
