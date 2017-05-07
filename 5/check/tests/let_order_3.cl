class Main inherits IO{
    keeper: Int;
    bool : Bool <- false;
    disp(): Int {{bool <- true; keeper<-keeper+1;}};
    main() : Object{
    {
        let a : Int <- disp(), a: Int <- disp(), a: Int <- disp() in{
            if bool then
                out_string("True\n")
            else
                out_string("False\n")
            fi;
            out_int(a);
        };
        out_int(keeper);
        out_string("\n");
    }
    };
};
