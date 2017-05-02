class Main inherits IO{
    so: Object <- self.copy();
    main() : Object{
        if self = so then
            out_string("EQUAL\n")
        else
            out_string("NEQ\n")
        fi
    };
};
