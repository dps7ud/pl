class Main inherits IO{
    bool : Bool <- false;
    t(): Object {{bool <- true; 4;}};
    f(): Object {{bool <- false; 4;}};
    main() : Object{
    {
        let a : Object <- t(), b: Object <- f() in
            if bool then
                out_string("True\n")
            else
                out_string("False\n")
            fi;
            5;
    }
    };
};
