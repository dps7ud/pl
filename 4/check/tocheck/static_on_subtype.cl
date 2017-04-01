class Main{
    main(): Object{
        let a : A <- (new B) in {
            a.put();
            a@B.put();
            a <- new A;
            a.put();
        }
    };
};

class A inherits IO{
    a : Int;
    put() : Object{ out_int(a) };
};

class B inherits A {
    b : Int;
};
