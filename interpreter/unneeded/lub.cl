class Main inherits IO{
    main() : Object{
        out_string((if false then
            new B
        else
            new C
        fi).type_name())
    };
};

class A{};
class B inherits A{};
class C inherits A{};
