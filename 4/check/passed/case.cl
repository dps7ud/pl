class Main inherits IO{
    main() : Object {
        {
            8;
            out_string("Hello, world");
        }
    };
};

class A inherits IO{
    switch(a: Object) : Object{
        {
            case a of
                e : E => out_string("Class type is now E\n");
                o : Object => out_string("Oooops\n");
            esac;
        }
    };
};

class E{};
