Class Main inherits IO { 
    main() : Object { 
        let 
            tasks : List <- new Nil, -- A sorted list of all tasks
            num_tasks : Int <- 0,    -- Number of unique tasks
            pairs : List <- new Nil, -- Pairs of tasks,  idicating dependence
            ans : List <- new Nil,   -- Our constructed order
            can_read : Bool <- true, -- "There are more lines to read"
            done : Bool <- false     -- "We have a solution or cycle is found"
        in {
            while can_read loop {
                let a : String <- in_string (), b : String <- in_string () in 
                if b = "" then
                    can_read <- false 
                else {
                    if not tasks.contains( (new Sop).str(a) ) then
                        tasks <- tasks.insert( (new Sop).str(a))
                    else true fi;
                    if not tasks.contains( (new Sop).str(b) ) then
                        tasks <- tasks.insert( (new Sop).str(b))
                    else true fi;
                    pairs <- pairs.cons( (new Sop).pair(a, b));
                }
                fi ;
          } pool ;
          num_tasks <- tasks.len();

          while not done loop{
              out_string("------------\n");
              let post : List <- pairs.firsts(),
              avail : List <- tasks.difference(post),
              choice : Sop <- avail.hd() (*if choice is uninitialized, 
                                          it came from an empty list *)
              in{
                  out_int(ans.len());
                  out_string(" ans\n");
                  ans.print_list();
                  if avail.is_empty() then
                      done <- true
                  else
                      {
                      ans <- (new Cons).init(choice, ans);
                      pairs <- pairs.filtertwo(choice.getone());
                      tasks <- tasks.filterone(choice.getone());
                      }
                  fi;
                  post <- pairs.firsts();
                  avail <- tasks.difference(post);
                  out_string("=================\n");
              };
          } pool;

          if ans.len() = num_tasks then
              ans.reverse( (new Nil) ).print_list()
          else
              out_string("cycle\n")
          fi;
        }
    };
};

Class Sop {
    (* String or pair: rather than implement two different
     * list classes, we simply abstract the datatype of each
     * node. If we need a string list, simply use 'one' and
     * set ispair <- true. ispair exists so that comparisons
     * between pairs and singletons will evaluate as desired.
    *)
    one : String;
    two : String;
    ispair : Bool;
    initialized : Bool;

    getone() : String { one };
    gettwo() : String { two };
    getispair() : Bool {ispair}; -- Defaults to false
    isinit() : Bool {initialized};

    str(s : String) : Sop {{initialized <- true; one <- s; self;}};

    pair(a : String, b : String) : Sop {
        {
        one <- a;
        two <- b;
        ispair <- true;
        initialized <- true;
        self;
        }
    };

    cmp(other : Sop) : Bool {
        if ispair = other.getispair() then
            if one = other.getone() then
                if two = other.gettwo() then
                    true
                else
                    false
                fi
            else
                false
            fi
        else
            false
        fi
    };
};

Class List inherits IO { 
    (* Weimer's provided List implementation edited to
     * operate on pairs of strings (using the first in
     * cases where we require a list of strings)
    *)
    

    cons(hd : Sop) : Cons { 
      let new_cell : Cons <- new Cons in
        new_cell.init(hd,self)
    };
    contains(sop : Sop) : Bool {false};
    difference(lst : List) : List {self};
    filterone(st : String) : List {self};
    filtertwo(st : String) : List {self};
    firsts() : List {self};
    insert(i : Sop) : List { self };
    is_empty() : Bool {true};
    hd() : Sop {(new Sop)};
    len() : Int {0};
    print_list() : Object { abort() };
    reverse(other : List) : List {self};
    seconds() : List {self};
    tl() : List {self};
} ;

Class Cons inherits List {
    -- Nonempty extension of list
    xcar : Sop;
    xcdr : List;

    init(hd : Sop, tl : List) : Cons {
      {
        xcar <- hd;
        xcdr <- tl;
        self;
      }
    };

    contains(sop : Sop) : Bool {
        if sop.cmp(xcar) then
            true
        else
            xcdr.contains(sop)
        fi
    };

    difference(lst : List) : List {
        if lst.contains(xcar) then
            xcdr.difference(lst)
        else
            (new Cons).init(xcar, xcdr.difference(lst))
        fi
    };

    firsts () : List {
        -- Extracts list of strings from a list of pairs by 
        -- taking the second string in each pair
        let rest : List <- xcdr.firsts(),
        current : Sop <- (new Sop).str( xcar.getone() ) in {
            if rest.contains(current) then
                rest
            else
                (new Cons).init(current, xcdr.firsts())
            fi;
        }
    };

    filterone(st : String) : List {
        if xcar.getone() = st then
            xcdr.filterone(st)
        else
            (new Cons).init(xcar, xcdr.filterone(st) )
        fi
    };

    filtertwo(st : String) : List {
        if xcar.gettwo() = st then
            xcdr.filtertwo(st)
        else
            (new Cons).init(xcar, xcdr.filtertwo(st) )
        fi
    };

    insert(s : Sop) : List {
    -- insert may not function as desired on a list of pairs
        if not (xcar.getone() < s.getone()) then
            (new Cons).init(s,self)
        else
            (new Cons).init(xcar,xcdr.insert(s))
        fi
    };

    is_empty() : Bool {false};

    hd() : Sop {xcar};

    len() : Int {xcdr.len() + 1};

    print_list() : Object {
        {
             out_string(xcar.getone());
             out_string(xcar.gettwo());
             out_string("\n");
             xcdr.print_list();
        }
    };

    reverse(other : List) : List {
        xcdr.reverse((new Cons).init(xcar, other))
    };

    seconds () : List {
        -- Extracts list of strings from a list of pairs by 
        -- taking the second string in each pair
        let rest : List <- xcdr.seconds(),
        current : Sop <- (new Sop).str( xcar.gettwo() ) in {
            if rest.contains(current) then
                rest
            else
                (new Cons).init(current, xcdr.seconds())
            fi;
        }
    };

    tl() : List {xcdr};
} ;

Class Nil inherits List {
    (* Empty extension of List*)
    contains(sop : Sop) : Bool {false};
    difference(lst : List) : List {self};
    firsts() : List {new Nil};
    filterone(st : String) : List {self};
    filtertwo(st : String) : List {self};
    insert(s : Sop) : List { (new Cons).init(s,self) }; 
    is_empty() : Bool {true};
    hd() : Sop {(new Sop)};
    len() : Int {0};
    print_list() : Object { true };
    reverse(other : List) : List {other};
    seconds() : List {new Nil};
    tl() : List {self};
} ;
