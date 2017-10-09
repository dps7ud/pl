class Main{
    c : C <- (new C);
    main() : Object{
        let a : A <- (new A), c : B <- (new B) in {
            c <- (new C);
            a <- (new B);
            a@C.c();
        }
    };
};

class A{
    a() : Int {6};
};
class B inherits A{
    b() : Int {23};
};
class C inherits B{
    c() : Int {2};
};
