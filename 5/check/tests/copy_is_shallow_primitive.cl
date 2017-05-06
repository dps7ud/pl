class Main inherits IO{
    i: Int <- 10;
    main() : Object{
        let j: Int <- i.copy() in{
            out_int(i);
            out_string("\n");
            out_int(j);
            out_string("\n");
            if i = j then
                out_string("i = j\n")
            else
                out_string("i != j\n")
            fi;
        }
    };
};
