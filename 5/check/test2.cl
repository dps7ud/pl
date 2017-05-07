class Main inherits IO{
    main(): Object{{
        some_func(7);
        other_func("spiffy");
    }};
    some_func(i: Int): Int{
        {
            out_int(i);
            out_string("\n");
            self.other_func("abcd");
            i + i * i;
        }
    };
    other_func(s: String): Object{
        let a: Int <- 43, b: Int <- 4/2, c: Other in
            {
                (new IO).out_int(a);
                c <- new Other;
                if s.length() < b then
                    c.out_string(s)
                else
                    if s.length() = 0 then
                        out_string("empty")
                    else
                        c.out_string(s.substr(0,s.length() - 1))
                    fi
                fi;
                let var: Third <- new Third, val: Fourth <- new Fourth in{
                    out_int(var.does());
                    val.method("lorum ipsum dolor sit amet", 9);
                };
            }
    };
};

class Other inherits IO{
    t: Third <- new Third;
    func1(f: Fourth): Int{
        t.does()
    };
};

class Third inherits Main{
    i: Int <- 54321;
    does(): Int{
        i <- i + i
    };
};

class Fourth{
    s: String;
    method(s: String, i: Int): Object {{
        (new IO).out_string(s);
        let t: Third <- new Third in{
        while 0 < i loop{
            t.does();
            i <- i -1;
        }pool;
        (new IO).out_int(t.does());
        (new IO).out_string("\n");
        };
    }};
};
