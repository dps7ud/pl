class Main inherits IO{
    some : Object;
    other : Object <- new Object;
    test_void(o : Object) : Object{
        if isvoid o then
            out_string("void\n")
        else
            out_string("not void\n")
        fi
    };
    main() : Object{
        {
            test_void(some);
            test_void(other);
        }
    };
};
