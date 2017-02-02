open Pa1btree;
open Pa1b;
let t: int_tree = {data: 5, left: None, right: None};
let k: option int_tree = Some {data: 5, left: None, right: None};
print_int (root_data t);
print_newline();
/*draw_int_tree (int_tree_map (fun x => x +1) (t));*/
print_newline();
/*
let rec bt = fun (tr: option int_tree) : option int_tree => {
    if(tr == None){
        None
    } else {
        let ret = switch(tr){
            | Some tr => tr
        };
        Some ({data: root_data ret, left: (bt (left_child ret)), right: (bt (right_child ret))});
    };
};
*/
let int_tree_map = fun (f: int => int) (t: int_tree) : int_tree => {
    let rec bt = fun (tr: option int_tree) : option int_tree => {
        if(tr == None){
            None
        } else {
            let ret = switch(tr){
                | Some tr => tr
            };
            Some ({data: f(root_data ret), left: (bt (left_child ret)), right: (bt (right_child ret))});
        };
    };
    let x = switch(bt (Some t)){
        |Some x => x
    };
    x;
    
};

let print_bool = fun (b: bool) => {
    print_string (string_of_bool b);
    print_newline();
};

let print_list = fun (l: list int) => {
    | [] => ()
    | hd::tl => print_int hd; print_string(", "); print_list tl
}
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
/*
let x = switch(bt (Some root)){
    | Some x => x
};
*/
let y = int_tree_map (fun x => 10 * x) root;
print_newline();
draw_int_tree y;

print_bool (y == root);
print_bool (y === root);
pre_order root;
