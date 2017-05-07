class Main inherits IO{
    v : Bool <- false;
    w : Bool <- true;
    main() : Object{
        if v < w then
            out_string("v=x")
        else
            out_string("v!=x")
        fi
    };
};
