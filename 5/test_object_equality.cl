class Main inherits IO{
    a : A;
    b : A;
    c : A;
    main() : Object {
        {
            a <- (new A);--"hello";
            b <- a;
            c <- a.copy();
            if a = b then
                out_string("a=b\n")
            else
                out_string("a!=b\n")
            fi;
            if a = c then
                out_string("a=c\n")
            else
                out_string("a!=c\n")
            fi;
            if a = (new A) then
                out_string("a=new A\n")
            else
                out_string("a!=new A\n")
            fi;
        }
    };
};

class A{};
