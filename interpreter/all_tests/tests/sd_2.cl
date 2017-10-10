class Main inherits IO{
    main() :Object{
    {
        out_string(foo(4));
        out_string(foo(100));
    }
    };
    foo(i: Int): String{
        if i < 5 then
            "small\n"
        else
            "large\n"
        fi
    };
};
