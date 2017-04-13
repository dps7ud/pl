class Main inherits IO{
    s : String <- "abc";
    main() : Object{
        {
            out_string(s.concat("def"));
            out_string(s);
        }
    };
};
