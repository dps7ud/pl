/*
 * PA1b Tree representation
 * Kevin Angstadt
 * University of Virginia
 *
 * recall you can do: open Pa1btree;
 */
 
type tree 'a = {
    data: 'a,
    left: option (tree 'a),
    right: option (tree 'a)
};

/* accessor functions */
let root_data = fun (t: tree 'a) : int => t.data;
let left_child = fun (t: tree 'a) : option (tree 'a) => t.left;
let right_child = fun (t: tree 'a) : option (tree 'a)  => t.right;

/*
 * draw a tree on standard out.
 * t : the tree
 * repr : function for converting tree data to string
 */
let draw = fun (t: tree 'a) (repr: 'a => string) : unit => {
    let rec indent = fun (t: tree 'a) (prefix: string) => {
        switch (right_child t) {
            | None => ()
            | Some subt => indent subt (prefix ^"  ")
        };
        Printf.printf "%s--%s\n" prefix (repr (root_data t));
        switch (left_child t) {
            | None => ()
            | Some subt => indent subt (prefix ^ "  ")
        }
    };
    indent t "";
};

/* let's define an int_tree */
type int_tree = tree int;

/* draw an int_tree */
let draw_int_tree = fun (t: int_tree) : unit => {
    draw t (fun i => Printf.sprintf "%i" i)
}
