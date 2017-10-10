class Main{
    main() : Object{
        {
            (new A).put();
            (new B).put();
            (new B)@A.put();
        }
    };
};

class A inherits IO{
    put(): Object{ out_string("A\n")};
};

class B inherits A{
    put(): Object{ out_string("B\n")};
};
