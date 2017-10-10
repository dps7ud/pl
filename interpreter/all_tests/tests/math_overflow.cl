class Main inherits IO{
    i: Int <- 1000000000;
    main(): Object{
        while 0 < i loop{
            out_int(i);
            i <- i + i;
        } pool
    };
};
