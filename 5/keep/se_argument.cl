class Main {
    my_A : A <- new A;
    main() : Object{
        (new B).to_test(my_A.mod(), my_A.mod())
    };
};

class A{
    a : Int <- 5;
    mod() : Int{
        a <- a + 1
    };
};

class B inherits IO{
    to_test(i : Int, j : Int) : Object{
        out_int(5 * i + 11 * j)
    };
};
