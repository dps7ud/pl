class Main inherits IO{
    main() : Object{
        out_string((if false then
            new A
        else
            new B
        fi).type_name())
    };
};

class A{};
class B inherits A{};
