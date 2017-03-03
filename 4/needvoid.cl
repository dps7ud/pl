Class Main inherits IO {
    main() : Object {
        {
            let v : Vtest <- (new Vtest).i("Hello\n") 
            in {
                out_string(v.geta());
                let n : Vtest <- v.getb() in {
                    if n = v then
                        out_string("Is\n")
                    else
                        out_string("Isn't\n")
                    fi;
                out_string(v.geta());
                };
            };
        }
    };
};

Class Vtest {
    a : String;
    b : Vtest;
    i(s : String) : SELF_TYPE {
        {
        a <- s;
        self;
        }
    };
    geta() : String {
        a
    };
    getb() : Vtest {
        b
    };
};
