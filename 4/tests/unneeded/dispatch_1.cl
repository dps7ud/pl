class Main inherits IO{
    main(): Object{
        let a : A <- (new A), b : B <- (new B) in {
            a.put();
            b.put();
            b@A.put();
            let a : String <- "foo" in out_string(a);
            a <- (new B);
            a.put();
        }
    };
};

class A inherits IO{
    a : Int <- 1;
    put() : Object {out_int(a)};
};

class B inherits A {
    b : Int <- 2;
    put() : Object {out_int(b)};
};
