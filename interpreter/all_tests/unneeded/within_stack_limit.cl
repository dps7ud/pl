class Main inherits IO{
    push(i: Int) : Object{
        if i = 0 then
            0
        else
            push(i-1)
        fi
    };
    main() : Object{
        {
            push(998);
            out_string("Done\n");
        }
    };
};
