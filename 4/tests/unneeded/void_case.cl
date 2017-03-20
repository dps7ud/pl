class Main inherits IO{
    main() : Object{
        let x : Void <- (new StareIntoThe).void() in {
            case x of
               x: Void => out_string("void_case");
            esac;
        }
    };
};

class StareIntoThe {
    a : Void;
    setA() : Object {
        a <- (new Void)
    };
    void() : Void{
        a
    };
};

class Void{
    do() : Int {5};
};
