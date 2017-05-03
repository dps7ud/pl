class Main inherits IO{
    whatsthis(o: Object): Object{
        case o of
        i: Int => out_string("That's an int\n");
        s: String => out_string("That's a string\n");
        o: Object => out_string("Don't know but it's an object\n");
        esac
    };
    main(): Object{{
        whatsthis(4);
        whatsthis("HI");
        whatsthis(new IO);
    }};
};


