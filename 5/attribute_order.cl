class Main inherits IO{
    main() : Object {
        let a : A <- new A in
            {
                a;
                out_string("exiting\n");
            }
    };
};

class A{
    b : Object <- io.out_string("Assignment\n");
    io : IO <- new IO;
    --b : Object <- io.out_string("Assignment\n");
    -- Here order of declaration for attributes matters.
};

