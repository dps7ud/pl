class Main inherits IO{
    main() : Object {
        {
        if 8 then (new A) else (new B) fi;
        7;
        }
    };
};


class A inherits IO{
    
};

class B inherits A{
    
};

class C inherits B{
    
};
