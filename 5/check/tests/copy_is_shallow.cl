class Main{
    b : B <- new B;
    main() : Object {
        let duplicate : B <- b.copy() in
            {
                b.modify();
                b.put();
                (new IO).out_string("\n");
                duplicate.put();
                (new IO).out_string("\n");
            }
    };
};

class A{
    private : Int <- 5;
    get() : Int{ private};
    set(i: Int) : Int { private <- i};
};

class B inherits IO{
    my_A : A <- new A;
    put() : Object{
        out_int(my_A.get())
    };
    modify() : Object {
        my_A.set(my_A.get() + 7)
    };
};
