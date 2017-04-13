class Main inherits IO{
    i : Int;
    s : String;
    b : Bool;
    main() : Object {
        if i = 0 then
            if s.length() = 0 then
                if not b then
                    out_string("A")
                else
                    out_string("B")
                fi
            else
                out_string("C")
            fi
        else
            out_string("D")
        fi
    };
};
