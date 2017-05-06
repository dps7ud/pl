class Main inherits IO{
    i: Int <- 1;
    main(): Object{
        while not i = 11 loop{
            i <- in_int();
            out_int(i);
            out_string("\n");
        }pool
    };
};
