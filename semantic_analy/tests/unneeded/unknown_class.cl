class Main inherits IO{
    a : A <- (new A);
    main() : Object { 
        {
            a.bad_call();
            out_string("Hello, world.\n");
        }
    };
};
