class Main inherits IO{
    i: Int;
    check(): Bool{{
        i <- i + 1;
        i < 10;
    }};
    main(): Object{
        while check() loop {
            out_int(i);
            out_string("\n");
            if i = 7 then
                abort()
            else 3 fi;
        } pool
    };
};
