open Pa1btree;
open Pa1b;
let rec print_list = fun (l: list int) => {
    switch(l){
        | [] => print_newline()
        | [hd, ...tl] => print_int hd; print_string(", "); print_list tl
    };
};
let three = Some {data: 3, left: None, right: None};
let five =   Some {data: 5, left: None, right: None};
let six =    Some {data: 6, left: five, right: three};
let two =    Some {data: 2, left: None, right: None};
let seven =  Some {data: 7, left: two, right: six};
let four =   Some {data: 4, left: None, right: None};
let nine =   Some {data: 9, left: four, right: None};
let eight =    Some {data: 8, left: None, right: nine};
let root = {data: 1, left: seven, right: eight};
draw_int_tree root;

let print_bool = fun (b: bool) => {
    print_string (string_of_bool b);
    print_newline();
};

let l = pre_order root;
print_list l;
print_bool([] == l);
