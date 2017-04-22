open Typedefs

(**********************)
(** De-serialization **)
(**********************)

let lnum = ref 0
let fname = Sys.argv.(1)
let fin = open_in fname
let read () =
    lnum := (!lnum) + 1;
    input_line fin (*fix for \r\n*)

let rec range k =
    if k <= 0 then []
    else k :: (range (k-1))

let read_list worker =
    let temp = read() in
(*    printf "%s::%d\n" temp !lnum ;*)
    let k = int_of_string (temp(*read()*)) in
    let lst = range k in
    List.map (fun _ -> worker () ) lst

let read_list_arg worker arg=
    let temp = read() in
(*    printf "%s::%d\n" temp !lnum ;*)
    let k = int_of_string (temp(*read()*)) in
    let lst = range k in
    List.map (fun _ -> worker arg ) lst

(*read class map*)
let rec read_class_map () =
    read() ;
    read_list read_attrib_class

(*read implementation map*)
and read_imp_map () =
    read() ;
    List.flatten (read_list read_imp_class)

(*read parent map*)
and read_parent_map () =
    read() ;
    read_list read_sub_super

and read_sub_super ()=
    let sub = read() in
    let super = read() in
    (sub, super)

and read_imp_class ()= 
    let cname = read() in
    (*printf "imp cname: %s @%d\n" cname !lnum;*)
    let cm_list = read_list_arg read_cool_method cname in
    cm_list

(* Passed name is the class we're currently reading*)
and read_cool_method passed_name =
    let mname = read() in
    (*printf "cool_method mname: %s@%d\n" mname !lnum;*)
    let flist = read_list read in
    (*Toss out defining class, since we have the body*)
    let _ = read() in
    (*printf "cool_method def_class: %s@%d\n" def_class !lnum;*)
    let expr = read_exp () in

    ((passed_name, mname), (flist, expr))
    (*(mname, flist, def_class, expr)*)

and read_attrib () = match read() with
    | "no_initializer" ->
        let aname = read() in
        let atype = read() in
        (aname, atype, None)
    | "initializer" ->
        let aname = read() in
        let atype = read() in
        let expr = read_exp() in
        (aname, atype, Some expr)
    | x -> failwith ("Bad attribute kind: " ^x)

and read_attrib_class () =
    let cname = read () in
    let attrib_list = read_list read_attrib in
    (cname, attrib_list)

and read_exp () =
    let loc = read() in
(*    printf "exp loc: %s@%d\n" loc !lnum;*)
    let c_type = read() in
(*    printf "exp type: %s@%d\n" c_type !lnum;*)
    let ekind = read() in
(*    printf "exp kind: %s@%d\n" ekind !lnum;*)
    match ekind (*read()*) with
        | "assign" ->
                let _ = read() in
                let var = read() in
(*                printf "assign var: %s@%d\n" var !lnum;*)
                let init = read_exp() in
                (loc, c_type, Assign(var, init))
        | "block" ->
                let exp_list = read_list read_exp in
                (loc, c_type, Block exp_list)
        | "divide" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Divide(e1,e2))
        | "dynamic_dispatch" ->
                let e0 = read_exp() in
                let _ = read() in
                let mname = read() in
                let arglist = read_list read_exp in
                (loc, c_type, Dispatch(Some e0, mname, arglist))
        | "eq" ->
                let e0 = read_exp() in
                let e1 = read_exp() in
                (loc, c_type, Eq(e0, e1))
        | "false" -> (loc, c_type, Bool(false))
        | "identifier" ->
                (*TODO Why is there a lino here?*)
                let _ = read() in
                let vname = read() in
                (loc, c_type, Variable vname)
        | "internal" ->
                let internal_str = read() in
                (loc, c_type, Internal internal_str)
        | "if" ->
                let pred = read_exp() in
                let tr = read_exp() in
                let fl = read_exp() in
                (loc, c_type, If(pred, tr, fl))
        | "integer" -> 
                let temp = read() in
                (*printf "%s%d\n" temp !lnum;*)
                let ival = Int32.of_string (temp(*read ()*)) in
                (loc, c_type, Integer ival)
        | "isvoid" ->
                let e = read_exp() in
                (loc, c_type, Isvoid(e))
        | "le" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Le(e1, e2))
        | "lt" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Lt(e1, e2))
        | "minus" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Minus(e1,e2))
        | "negate" ->
                let expression = read_exp () in
                (loc, c_type, Neg(expression))
        | "new" ->
                (*TODO now I'm worrying I'm not handling 
                 * linenos correctly*)
                let _ = read() in
                let ntype = read() in
                (loc, c_type, New ntype)
        | "not" ->
                let expression = read_exp () in
                (loc, c_type, Not(expression))
        | "plus" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Plus(e1,e2))
        | "self_dispatch" ->
                let _ = read() in
                let mname = read() in
                let arglist = read_list read_exp in
                (loc, c_type, Dispatch(None, mname, arglist))
        | "static_dispatch" ->
                let e0 = read_exp() in
                let _ = read () in
                let static_class = read () in
                let _ = read () in
                let mname = read() in
                let arglist = read_list read_exp in
                (loc, c_type, Static(e0, static_class, mname, arglist))
        | "string" ->
                let sval = read() in
                (loc, c_type, String sval)
        | "times" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Times(e1,e2))
        | "true" -> (loc, c_type, Bool(true))
        | "while" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Loop(e1, e2))
        | x -> failwith ("Unhandled exp kind:: " ^ x)

