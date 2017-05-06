class Main inherits IO{
    a : String <- "a";
    b : String <- "Hello, world";
    c : String <- "with \escaped char\"\"s";
    d : String <- "\"";
    e : String <- "";
    put(s: String) : Object{
        {
            let len: Int <- s.length(), index: Int <- 0 in{
                while index < len loop{
                    out_string(s.substr(index, 1));
                    out_string("\n");
                    index <- index + 1;
                } pool;
                index <- 0;
                while index < len loop{
                    let jj: Int <- 0 in
                        while (jj + index) < len + 1 loop {
                            out_string(s.substr(index, jj));
                            jj <- jj + 1;
                        } pool;
                    out_string("\n");
                    index <- index + 1;
                } pool;
                
            };
        }
    };
    main(): Object{
        {
            put(a);
            put(b);
            put(c);
            put(d);
            put(e);
        }
    };
};
