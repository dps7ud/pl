class Main inherits IO{
    i : Int <- 7;
    main() : Object{
        while not (i=~1) loop
            {
                i <- in_int();
                out_int(i);
                out_string("\n");
            }
        pool
    };
};
