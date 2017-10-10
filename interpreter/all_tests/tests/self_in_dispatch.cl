class Main{
    main() : Object {
        {
            (new B).do();
            (new A).do();
        }
    };
};

class A inherits IO{
    do(): Object {
        case self of
            m: Main => {out_string("Main"); (new Main);};
            b: B => {out_string("B"); (new B);};
            a: A => {out_string("A"); (new A);};
            o: Object => {out_string("Object"); (new Object);};
        esac
    };
};

class B inherits A{};
