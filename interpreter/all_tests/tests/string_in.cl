class Main inherits IO{
    s : String <- "";
    main() : Object{
        while not (s=" ") loop
            {
                s <- in_string();
                out_string(s);
                out_string("\n");
                out_int(s.length());
                out_string("\n");
            }
        pool
    };
};
