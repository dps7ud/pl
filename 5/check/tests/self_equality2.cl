class Main inherits IO{
    so: Object;
(*    other: Object;*)
    main() : Object{{
        so <- self;
(*        other <- self.copy();*)
        if so = self then
            out_string("so is self\n")
        else
            out_string("so != self\n")
        fi;
        (*
        if other = self then
            out_string("other is self\n")
        else
            out_string("other != self\n")
        fi;
        *)
    }};
};
