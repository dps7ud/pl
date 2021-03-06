class Main inherits IO{
    main() : Object {
        let a : A <- (new A), b : B <- (new B) in {
            a.put();
            b.put();
            b@A.put();
            a <- b.copy();
            a.put();
            b.put();
            b@A.put();
            a@A.put();
            b <- a.copy();
        }
    };
};


class A inherits IO{
    put() : Object {out_string("A")};
    copy() : SELF_TYPE {self};
};

class B inherits A{
    put() : Object {out_string("B")};
    copy() : SELF_TYPE {self};
};
