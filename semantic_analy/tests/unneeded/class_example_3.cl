class Main{
    x : Int <- 4;
    main(): Object{
        let x : A <- (new B) in x <- (new A)
    };
};

class A {
    a : Int;
};

class B inherits A {
    b : Int;
};
