class Main inherits A{
    put() : Object{ out_string("Hello\n")};
    main() : Object{
        (new SELF_TYPE).put()
    };
};

class A inherits IO{
    put() : Object{ out_string("Hi\n")};
};
