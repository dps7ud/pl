class Main inherits IO{
    main() : Int {
        let a : A <- (new A), b : B <- (new B), c : C <- (new C) in {
            a.put();
            c.put();
            c@A.put();
            c@B.put();
            b.put();
            b@A.put();
            a <- b.copy();
            b <- c.copy();
            a.put();
            c.put();
            c@A.put();
            c@B.put();
            b.put();
            b@A.put();
            a <- c.copy();
            a.put();
            c.put();
            c@A.put();
            c@B.put();
            b.put();
            b@A.put();
            3;
        }
    };
};

class A inherits IO {
    copy() : SELF_TYPE {self};
    put() : Object {
        out_string("A")
    };
};

class B inherits A {};

class C inherits B {
    copy() : SELF_TYPE {self};
    put() : Object {
        out_string("C")
    };
};
