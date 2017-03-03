class Main inherits IO{
    main() : Object{
        let x : Void <- (new StareIntoThe).void() in {
            x.do();
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
