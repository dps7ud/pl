class Main inherits IO{
    b: B <- new B;
    s: String <- "Hello, world\n";
    main(): Object{{
        out_string(s.type_name());
        out_string(s@Object.type_name());
        b.do();
        b@A.do();
    }};
};
class A inherits IO {
    do(): Object{
        out_string("A\n")
    };
};
class B inherits A {
    do(): Object{
        out_string("B\n")
    };
};
