class Main inherits IO{
    so: Object;
    main() : Object{{
        so <- self;
        if so = self then
            out_string("so = self\n")
        else
            out_string("so != self\n")
        fi;
    }};
};
