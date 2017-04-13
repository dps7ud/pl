class Main inherits IO{
    a : Int <- 100;
    main() : Object {
        let obj : A <- new A in
            --while a < obj.get() loop
            while obj.get() < a loop
                {
                    obj <- obj.alter();
                    out_int(obj.get());
                    out_string("\n");
                }
            pool
    };
};

class A{
    num : Int <- 0;
    get() : Int { num};
    alter() : SELF_TYPE{
        {
            num <- num + 1;
            self;
        }
    };
};
