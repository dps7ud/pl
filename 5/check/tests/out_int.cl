class Main inherits IO{
    i : Int <- ~2147483647;
    main() : Object{
        while true loop{
            out_int(i);
            i <- i + 1000000;
            if 2000000000 < i then
                abort()
            else
                i
            fi;
        } pool
    };
};
