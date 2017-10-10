class Main inherits IO{
    v : IO;
    w : IO;
    x : IO <- new IO;
    main() : Object{
        {
            if v = w then
                out_string("v=w")
            else
                out_string("v!=w")
            fi;
            if v = x then
                out_string("v=x")
            else
                out_string("v!=x")
            fi;
        }
    };
};
