class Main inherits IO{
    v : Bool <- false;
    w : Bool <- true;
    main() : Object{
    {
        if v < w then
            out_string("v=x\n")
        else
            out_string("v!=\nx")
        fi;
        if w < v then
            out_string("A\n")
        else
            out_string("B\n")
        fi;
    }
    };
};
