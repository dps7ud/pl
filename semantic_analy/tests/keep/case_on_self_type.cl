class Main inherits IO{
    i : Int;
    main() : Object {
        case i of
            s : String => "string";
            st : SELF_TYPE => self;
            o : Object => i;
        esac
    };
};
