class Main inherits IO{
    a : A;
    b : A;
    c : A <- new A;
    main() : Object{
        {
            if a = b then
                out_string("A")
            else
                out_string("B")
            fi;
            if a = c then
                out_string("C")
            else
                out_string("D")
            fi;
         }
    };
};

class A{};
