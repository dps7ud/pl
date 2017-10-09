class Main{
    a : A <- new A;
    b : B <- new B;
    main() : Object {
        {
            a.wrapper();
            b.wrapper();
            b@A.wrapper();
            a.method();
            b.method();
            a <- (new B);
            a.wrapper();
            a.method();
            a@A.wrapper();
        }
    };
};

class A inherits IO{
    method() : Object{
        out_string("A")
    };
    wrapper() : Object{
        method()
    };
};

class B inherits A{
    method() : Object{
        out_string("B")
    };
};
