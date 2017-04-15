open Printf

(*
type class_map = attrib_class list
and id = string
and linum = string
and cool_type = string (*id*)
and attrib_class = id * attrib list
and attrib = id * cool_type * (exp option)
*)
type class_map = (string * ((string * exp) list)) list
and exp = linum * cool_type * exp_kind
and exp_kind =
    | New of string
    | Dispatch of exp * string * (exp list)
    | Variable of string
    | Assign of string * exp
    | Integer of Int32.t
    | Plus of exp * exp
    | String of string
    | Internal of string (*Object.copy &c.*)
(*
type imp_map = imp_class list
and imp_class = id * cool_method list
and cool_method =  id * formal list * id * exp (*class, flist, defining class, body*)
and formal = string
*)

type imp_map = 
    (*cname,     mname*)
    ( (string * string)
    *
    (*formal list,  body*)
    ((string list) * exp) ) list

type parent_map = (string * string) list
(*
type parent_map = sub_super list
and sub_super = id * id (*child, parent*)
*)

type cool_address = int
type cool_value =
    | Cool_Int of Int32.t
    | Cool_Bool of bool
    | Cool_String of string
    | Cool_Object of string * ((string * cool_address) list)
    | Void

type environment = (string * cool_address) list
type store = (cool_address * cool_value) list

(***************************)
(** Debugging and Tracing **)
(***************************)
let do_debug = ref true
let debug fmt=
    let handle result_string =
        if !do_debug then printf "%s" result_string
    in
    kprintf handle fmt

let rec exp_to_str expr =
    match expr with
    | (_,_,New(s)) -> sprintf "New(%s)" s
    | (_,_,Dispatch(obj, fname, args)) -> 
            let arg_str = List.fold_left (fun acc elt ->
                acc ^ ", " ^ (exp_to_str elt)
            ) "" args in
            (* "" (List.map (fun (_,_,e) -> e) args) in*)
            sprintf "Dispatch(%s, %s, [%s])" (exp_to_str obj) fname arg_str
    | (_,_,Variable(x)) -> sprintf "Variable(%s)" x
    | (_,_,Assign(x, e)) -> sprintf "Assign(%s, %s)" x (exp_to_str e)
    | (_,_,Integer(i)) -> sprintf "Integer(%ld)" i
    | (_,_,Plus(e1, e2)) -> sprintf "Plus(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,String(s)) -> sprintf "String(%s)" s
    | (_,_,Internal(s)) -> sprintf "Internal(%s)" s

let value_to_str v =
    match v with
    | Cool_Int(i) -> sprintf "Int: %ld" i
    | Cool_Bool(b) -> sprintf "Bool: %b" b
    | Cool_String(s) -> sprintf "String: %s" s
    | Void -> sprintf "Void"
    | Cool_Object(cname, attrs) ->
            let attr_str = List.fold_left (fun acc (aname, aaddr) ->
                sprintf "%s, %s=%d" acc aname aaddr
            ) "" attrs in
            sprintf "%s([%s])" cname attr_str

let env_to_str env =
    let binding_str = List.fold_left (fun acc (aname, aaddr) ->
        sprintf "%s, %s=%d" acc aname aaddr
    ) "" env in
    sprintf "[%s]" binding_str

let store_to_str store_in =
    let store_str = List.fold_left (fun acc (addr, cvalue) ->
        sprintf "%s, %d=%s" acc addr (value_to_str cvalue)
    ) "" store_in in
    sprintf "[%s]" store_str

let indent_count = ref 0
let debug_indent () =
    debug "%s" (String.make !indent_count ' ')


(****************)
(** Evaluation **)
(****************)
let rec eval (so : cool_value)    (* self object *)
             (s : store)          (* _the_ store *)
             (e : environment)    (* _the_ environment *)
             (expr : exp)         (* expression to evaluate *)
             :
             (cool_value * store) (*resulting value and updated store*)
             =
    indent_count := !indent_count + 2;
    debug_indent () ; debug "so: %s\n" (value_to_str so);
    debug_indent () ; debug "eval: %s\n" (exp_to_str expr);
    debug_indent () ; debug "store: %s\n" (store_to_str s);
    debug_indent () ; debug "env: %s\n" (env_to_str e);
    let new_val, new_store = match expr with
    | (_,_,Integer(i)) -> Cool_Int(i), s
    | (_,_,Plus(e1,e2)) -> 
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            let result_value = match v1, v2 with
            | Cool_Int(i1), Cool_Int(i2) -> 
                    Cool_Int(Int32.add i1 i2)
            | _,_ -> failwith "Bad plus"
            in
            result_value, s3
    | (_,_,New(cname)) ->
    | _ -> failwith "Unhandled expr type"
    in
    debug_indent(); debug "ret = %s\n" (value_to_str new_val);
    debug_indent(); debug "store after = %s\n" (store_to_str new_store);
    indent_count := !indent_count - 2;
    new_val, new_store


(**********************)
(** De-serialization **)
(**********************)

let main () = begin
    let lnum = ref 0 in
    let fname = Sys.argv.(1) in
    let fin = open_in fname in
    let read () =
        lnum := (!lnum) + 1;
        input_line fin (*fix for \r\n*)
    in

    let rec range k =
        if k <= 0 then []
        else k :: (range (k-1))
    in

    let read_list worker =
        let temp = read() in
        (*printf "%s::%d\n" temp !lnum ;*)
        let k = int_of_string (temp(*read()*)) in
        let lst = range k in
        List.map (fun _ -> worker () ) lst
    in

    (*read class map*)
    let rec read_class_map () =
        read() ;
        read_list read_attrib_class

    (*read implementation map*)
    and read_imp_map () =
        read() ;
        read_list read_imp_class

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
        let cm_list = read_list read_cool_method in
        (cname, cm_list)

    and read_cool_method () =
        let mname = read() in
        (*printf "cool_method mname: %s@%d\n" mname !lnum;*)
        let flist = read_list read_formal in
        let def_class = read() in
        (*printf "cool_method def_class: %s@%d\n" def_class !lnum;*)
        let expr = read_exp () in
        (mname, flist, def_class, expr)

    and read_formal () =
        let fname = read() in
        (*printf "fname: %s\n" fname;*)
        fname

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
        (*printf "exp loc: %s@%d\n" loc !lnum;*)
        let c_type = read() in
        match read () with
            | "integer" -> 
                    let temp = read() in
                    (*printf "%s%d\n" temp !lnum;*)
                    let ival = Int32.of_string (temp(*read ()*)) in
                    (loc, c_type, Integer ival)
            | "string" ->
                    let sval = read() in
                    (loc, c_type, String sval)
            | "internal" ->
                    let internal_str = read() in
                    (loc, c_type, Internal internal_str)
            | x -> failwith ("Unhandled exp kind: " ^ x)
    in

    let cm = read_class_map () in
    let im = read_imp_map () in
    let pm = read_parent_map () in
    close_in fin ;
    printf "CM deserialized: %d classes\n" (List.length cm);
    printf "IM deserialized: %d classes\n" (List.length im);
    printf "PM deserialized: %d pairs\n" (List.length pm);
    let my_expr = ("0", "Int",Plus(("0","Int",Integer(5l)),("0","Int",Integer(3l)))) in
    debug "my_expr = %s\n" (exp_to_str my_expr);

    let init_so = Void in
    let init_store = [] in
    let init_env = [] in
    let final_val, final_store =
        eval init_so init_store init_env my_expr in
    debug "result = %s\n" (value_to_str final_val)

end;;
main();;
