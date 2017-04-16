class Main inherits IO{
    o: Object;
    main() : Object{
        {
            o <- out_string("Hello, world\n");
            out_string(o.type_name());
            out_string("\n");
        }
    };
};
