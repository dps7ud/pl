Class Main inherits IO {
    main() : Object {
        {
        out_string("hsdf\n");
        let s : String <- "Hello worl" in 
        out_string(s);
        }
    };
};

Class Func inherits IO {
    mult(a : Int, b : Int) : Int {
        {
        if a = 1 then
            b
        else
            b + self.mult(a-1, b)
        fi ;
        }
    };
};

(*
if s = "" then (* if we are done reading lines
                * then s will be "" *) 
  done <- true 
else 
  l <- l.cons(s) -- insertion sort it into our list
fi ;
*)
(*        let f : Func <- new Func
        let i:Int <- (new Func).mult(4,5) in out_int(i);
        true
        in {
            f.mult(4,5)
        }
*)
