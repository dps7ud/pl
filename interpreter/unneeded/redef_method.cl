class Main inherits IO{
    main() : Object{
        {
            out_int( (new A).get());
            out_string("\n");
            out_int( (new B).get());
            out_string("\n");
            out_int( (new B)@A.get());
            out_string("\n");
        }
    };
};

class A{
    get() : Int{8};
};
class B inherits A{
    get() : Int{2};
};
