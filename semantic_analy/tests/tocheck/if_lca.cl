class Main inherits IO{
    b : B;
    main() : Object {
        {
        b <- if true then (new C) else (new B) fi;
        }
    };
};


class A inherits IO{
};

class B inherits A{
};

class C inherits A{
};
