class Main{
    b : B <- new A;
    main() : Object{
        let b : B <- (new A) in 4
    };
};

class A{};
class B inherits A{};
