class Main inherits IO{
    p: Object;
    bool : Bool <- false;
    disp(): Object {{bool <- true; 4;}};
    main() : Object{
    p<-{
        let a : Object <- disp() in
            if bool then
                out_string("True\n")
            else
                out_string("False\n")
            fi;
        1;
    }
    };
};
