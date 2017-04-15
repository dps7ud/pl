open Printf

(*
type class_map = attrib_class list
and id = string
and linum = string
and cool_type = string (*id*)
and attrib_class = id * attrib list
and attrib = id * cool_type * (exp option)
*)
(*               cname       (name type initializer?) list *)
type class_map = (string * ( (string * string * exp option) list)) list
and exp = string * string * exp_kind
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
    | Cool_String of string * int
    | Cool_Object of string * ((string * cool_address) list)
    | Void

type environment = (string * cool_address) list
type store = (cool_address * cool_value) list
let new_location_counter = ref 1000
let newloc () =
    incr new_location_counter ;
    !new_location_counter 

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
    | Cool_Int(i) -> sprintf "Int(%ld)" i
    | Cool_Bool(b) -> sprintf "Bool(%b)" b
    | Cool_String(s, i) -> sprintf "String(%s, %d)" s i
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
    (*printf "%s::%d\n" temp !lnum ;*)
    let k = int_of_string (temp(*read()*)) in
    let lst = range k in
    List.map (fun _ -> worker () ) lst

let read_list_arg worker arg=
    let temp = read() in
    (*printf "%s::%d\n" temp !lnum ;*)
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

let cm = read_class_map ()
let im = read_imp_map ()
let pm = read_parent_map ();;

(*
let implementation_transform imp_cl =
    match imp_cl with
    | (cname, cm_list) ->

and cm_transform cm =
    match cm with
    | (mname, flist, def_class, expr)

*)
    (*
and read_imp_class ()= 
    let cname = read() in
    let cm_list = read_list read_cool_method in
    (cname, cm_list)
    *)
(*
type imp_map = 
    (*cname,     mname*)
    ( (string * string)
    *
    (*formal list,  body*)
    ((string list) * exp) ) list
    *)

close_in fin ;;

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
    (*class_map = (string * ((string * string * exp) list)) list*)
    | (_,_, Assign(vname, rhs)) ->
            let v1, s2 = eval so s e rhs in
            let l1 = List.assoc vname e in
            let s3 = (l1, v1) :: List.remove_assoc l1 s2 in
            v1, s3
    | (_,_, New("SELF_TYPE")) -> failwith "implement New S_T"
    | (_,_, New(cname)) ->
            let attrs_and_inits = List.assoc cname cm in
            let new_attr_locs = List.map (fun (aname, atype, ainit) ->
                newloc ()
            ) attrs_and_inits in

            let attr_names = List.map (fun (aname, atype, ainit) ->
                aname) attrs_and_inits in
            let attrs_and_locs = List.combine attr_names new_attr_locs in

            let attr_types = List.map (fun (aname, atype, ainit) ->
                atype) attrs_and_inits in
            let types_and_locs = List.combine attr_types new_attr_locs in

            let v1 = Cool_Object(cname, attrs_and_locs) in
            let store_updates = List.map (fun (atype, loc) ->
                match atype with
                | "Int" -> (loc,Cool_Int(0l))
                | "String" -> (loc, Cool_String("",0))
                | "Bool" -> (loc, Cool_Bool(false))
                | _ -> (loc, Void)
            ) types_and_locs in
            let s2 = s @ store_updates in
            let initialized_attribs = List.filter (fun triple ->
                match triple with
                | (_,_, None) -> false
                | _ -> true
            ) attrs_and_inits in
            (*TODO getting a warning about matching (_,_,None) but I thought
             * I took care of this above (and below). Tests on uninitialized
             * attributes seem to work.*)
            let final_store = List.fold_left (fun acc_store (aname, atype, Some ainit) ->
                match (aname, atype, Some ainit) with
                | (_,_,None) -> failwith "attribute without init"
                | _ -> let _, updated_store = 
                    (*TODO make custom *init* exp to handle this. Easier debugging*)
                    eval v1 acc_store attrs_and_locs ("0","Int",Assign(aname, ainit)) in
                updated_store
            ) s2 initialized_attribs in
            v1, final_store
(*            let new_attr_locs = List.map (fun (aname, atype, ainit) ->*)
            
(*            failwith "Do initialize as assignments"*)

    | _ -> failwith "Unhandled expr type"
    in
    debug_indent(); debug "ret = %s\n" (value_to_str new_val);
    debug_indent(); debug "store after = %s\n" (store_to_str new_store);
    indent_count := !indent_count - 2;
    new_val, new_store

let main () = begin
    (*
    printf "CM deserialized: %d classes\n" (List.length cm);
    printf "IM deserialized: %d classes\n" (List.length im);
    printf "PM deserialized: %d pairs\n" (List.length pm);

    let func_1 sub_super =
        match sub_super with
        | (sub, super) -> printf "%s is the parent class of %s\n" super sub in
    List.map func_1 pm;




    let func_2 imp_class =
        match imp_class with
        | ((cname, mname), (flist, _) ) ->
            printf "Class %s, method %s has %d formals and a body\n" cname mname (List.length flist)
    in
    List.map func_2 im;




    let attr_to_str attr =
        match attr with
        | (id, tname, Some expr) -> sprintf "id:%s type:%s expr:%s" id tname (exp_to_str expr)
        | (id, tname, None) -> sprintf "id: %s type: %s" id tname
    in

    let func_3 cool_class =
        match cool_class with
        | (cname, attrs) -> 
            let att_str = List.fold_left (fun acc elt ->
                acc ^ ", " ^ (attr_to_str elt) ^ "\n"
            ) "" attrs in
            printf "CLASS: %s\n ATTRS:\n %s\n" cname att_str
    in
    List.map func_3 cm;
    *)



    let my_expr = ("0", "Int",Plus(("0","Int",Integer(5l)),("0","Int",Integer(3l)))) in
    debug "my_expr = %s\n" (exp_to_str my_expr);
    
    let my_new = ("0", "Main", New("Main")) in
    debug "my_new = %s\n" (exp_to_str my_new);

    let init_so = Void in
    let init_store = [] in
    let init_env = [] in
    let final_val, final_store =
(*        eval init_so init_store init_env my_expr in*)
        eval init_so init_store init_env my_new in
    debug "result = %s\n" (value_to_str final_val);

end;;
main();;
