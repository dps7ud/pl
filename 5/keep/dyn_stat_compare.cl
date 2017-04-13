class Main inherits IO{
    a : A <- new A;
    b : A <- new B;
    main() : Object{
        {
            if a < b then
                out_string("a<b\n")
            else
                out_string("a!<b\n")
            fi;
            if a < b then
                out_string("a<b\n")
            else
                out_string("a!<b\n")
            fi;
        }
    };
};

class A{};
class B inherits A{};
