open Printf

(**********************)
(** Type Definitions **)
(**********************)
(*               cname       (name type initializer?) list *)
type class_map = (string * ( (string * string * exp option) list)) list
and exp = string * string * exp_kind
and exp_kind =
    | Assign of string * exp
    | Bool of bool
            (*e0      id       type     do*)
    | Block of exp list
    | Case of exp * ((string * string * exp) list)
    | Dispatch of (exp option) * string * (exp list)
    | Divide of exp * exp
    | Eq of exp * exp
    | If of exp * exp * exp
    | Integer of Int32.t
    | Internal of string (*Object.copy &c.*)
    | Isvoid of exp
    | Le of exp * exp
            (*id        type     assign?            body*)
    | Let of (string * string * (exp option)) list * exp
    | Loop of exp * exp
    | Lt of exp * exp
    | Minus of exp * exp
    | New of string
    | Neg of exp
    | Not of exp
    | Plus of exp * exp
    | Self
    | String of string
    | Static of exp * string * string * (exp list)
    | Times of exp * exp
    | Variable of string

type imp_map = 
    (*cname,     mname*)
    ( (string * string)
    *
    (*formal list,  body*)
    ((string list) * exp) ) list

type parent_map = (string * string) list
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
let do_debug = ref false
let debug fmt=
    let handle result_string =
        if !do_debug then printf "%s" result_string
    in
    kprintf handle fmt

let rec exp_to_str expr =
    match expr with
    | (_,_,Assign(x, e)) -> sprintf "Assign(%s, %s)" x (exp_to_str e)
    | (_,_,Bool(b)) -> sprintf "Bool(%b)" b
    | (_,_,Block(explist)) ->
            let exp_str = List.fold_left (fun acc elt ->
                acc ^ ", " ^ (exp_to_str elt)
            ) "" explist in
            sprintf "Block([%s])" exp_str
    | (_,_,Case(e0, case_list)) ->
            let case_str = List.fold_left (fun acc elt ->
                begin match elt with
                | (id, ctype, e) ->
                        acc ^ ", " ^ id ^ ": " ^ ctype ^ " => " ^ (exp_to_str e)
                end
            ) "" case_list in
            sprintf "Case(%s of %s)" (exp_to_str e0) case_str
          (*id       type     do*)
        (*((string * string * exp) list)*)
    | (_,_,Dispatch(None, fname, args)) -> 
            let arg_str = List.fold_left (fun acc elt ->
                acc ^ ", " ^ (exp_to_str elt)
            ) "" args in
            (* "" (List.map (fun (_,_,e) -> e) args) in*)
            sprintf "Dispatch(<self>, %s, [%s])" fname arg_str
    | (_,_,Dispatch(Some obj, fname, args)) -> 
            let arg_str = List.fold_left (fun acc elt ->
                acc ^ ", " ^ (exp_to_str elt)
            ) "" args in
            (* "" (List.map (fun (_,_,e) -> e) args) in*)
            sprintf "Dispatch(%s, %s, [%s])" (exp_to_str obj) fname arg_str
    | (_,_,Divide(e1, e2)) -> sprintf "Divide(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,If(a,b,c)) -> sprintf "If(%s,%s,%s)" (exp_to_str a) (exp_to_str b) (exp_to_str c)
    | (_,_,Integer(i)) -> sprintf "Integer(%ld)" i
    | (_,_,Internal(s)) -> sprintf "Internal(%s)" s
    | (_,_,Minus(e1, e2)) -> sprintf "Minus(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,New(s)) -> sprintf "New(%s)" s
    | (_,_,Plus(e1, e2)) -> sprintf "Plus(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,Self) -> sprintf "Self"
    | (_,_,String(s)) -> sprintf "String(\"%s\")" s
    | (_,_,Times(e1, e2)) -> sprintf "Times(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,Variable(x)) -> sprintf "Variable(%s)" x
    | x -> failwith("No to string for expression ")

let value_to_str v =
    match v with
    | Cool_Int(i) -> sprintf "Int(%ld)" i
    | Cool_Bool(b) -> sprintf "Bool(%b)" b
    | Cool_String(s, i) -> sprintf "String(\"%s\", %d)" s i
    | Void -> sprintf "Void"
    | Cool_Object(cname, attrs) ->
            let attr_str = List.fold_left (fun acc (aname, aaddr) ->
                sprintf "%s, %s=%d" acc aname aaddr
            ) "" attrs in
            sprintf "%s([%s])" cname attr_str

let env_to_str env =
    let binding_str = List.fold_left (fun acc (aname, aaddr) ->
        sprintf "%s, %s=%d" acc aname aaddr
    ) "" (List.sort compare env) in
    sprintf "[%s]" binding_str

let store_to_str store_in =
    let store_str = List.fold_left (fun acc (addr, cvalue) ->
        sprintf "%s, %d=%s" acc addr (value_to_str cvalue)
    ) "" (List.sort compare store_in) in
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
(*        | "eq"*)
(*        | "false"*)
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
(*        | "le"*)
(*        | "lt"*)
        | "minus" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Minus(e1,e2))
(*        | "negate"*)
        | "new" ->
                (*TODO now I'm worrying I'm not handling 
                 * linenos correctly*)
                let _ = read() in
                let ntype = read() in
                (loc, c_type, New ntype)
(*        | "not"*)
        | "plus" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Plus(e1,e2))
        | "self_dispatch" ->
                let _ = read() in
                let mname = read() in
                let arglist = read_list read_exp in
                (loc, c_type, Dispatch(None, mname, arglist))
(*        | "static_dispatch"*)
        | "string" ->
                let sval = read() in
                (loc, c_type, String sval)
        | "times" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                (loc, c_type, Times(e1,e2))
        | "true" ->
                (loc, c_type, Bool(true))
(*        | "while"*)
        | x -> failwith ("Unhandled exp kind:: " ^ x)

let cm = read_class_map ()
let im = read_imp_map ()
let pm = read_parent_map ();;
close_in fin ;;

(****************)
(** Evaluation **)
(****************)

let rec str_format str =
  try
    let i = String.index str '\\' in
    if String.length str > i + 1 && str.[i+1] == 'n' then
        (String.sub str 0 i) 
        ^ "\n" 
        ^ (str_format (String.sub str (i + 2) ((String.length str) - (i + 2)) ))
    else 
        if String.length str > i + 1 && str.[i+1] == 't' then
        (String.sub str 0 i) 
        ^ "\t" 
        ^ (str_format (String.sub str (i + 2) ((String.length str) - (i + 2)) ))
        else
            str
  with Not_found -> str;;

let err linum msg =
    printf "ERROR: %s: Exception: %s\n" linum msg;
    exit 1

let rec eval (so : cool_value)    (* self object *)
             (s : store)          (* _the_ store *)
             (e : environment)    (* _the_ environment *)
             (expr : exp)         (* expression to evaluate *)
             :
             (cool_value * store) (*resulting value and updated store*)
             =
    indent_count := !indent_count + 2;
    debug "\n";
    debug_indent () ; debug "eval.:%s\n" (exp_to_str expr);
    debug_indent () ; debug "so...=%s\n" (value_to_str so);
    debug_indent () ; debug "store=%s\n" (store_to_str s);
    debug_indent () ; debug "env..=%s\n" (env_to_str e);
    let new_val, new_store = match expr with
    | (_,_, Assign(vname, rhs)) ->
            let v1, s2 = eval so s e rhs in
            let l1 = List.assoc vname e in
            let s3 = (l1, v1) :: List.remove_assoc l1 s2 in
            v1, s3
    | (_,_, Block(exp_list)) ->
            let final_pair = List.fold_left (fun acc elt ->
                begin match acc with
                | (obj, st) -> eval so st e elt
                end
            ) (Void, s) exp_list in
            final_pair
    | (_,_, Bool(b)) -> Cool_Bool(b), s
    | (loc,_, Dispatch(None, fname, args)) ->
            let current_store = ref s in
            let arg_values = List.map (fun arg_exp ->
                let arg_value, new_store = eval so !current_store e arg_exp in
                current_store := new_store;
                arg_value
            ) args in
            (*No e0 to evaluate so we continue with v0:=so*)
            let s_n2 = !current_store in
            let v0 = so in
            begin match v0 with
            | Void -> err loc "dispatch on void"
            | Cool_Object (x, attrs_and_locs) ->
                    let formals, body = List.assoc (x, fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs @ attrs_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_String(_,_) ->
                    let formals, body = List.assoc ("String", fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_Bool(_) ->
                    let formals, body = List.assoc ("Bool", fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_Int(_) ->
                    let formals, body = List.assoc ("Int", fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body
            end
    | (loc,_, Dispatch((Some e0), fname, args)) ->
            let current_store = ref s in
            let arg_values = List.map (fun arg_exp ->
                let arg_value, new_store = eval so !current_store e arg_exp in
                current_store := new_store;
                arg_value
            ) args in
            let v0, s_n2 = eval so !current_store e e0 in
            begin match v0 with

            | Void -> err loc "dispatch on void"

            | Cool_Object (x, attrs_and_locs) ->
                    let formals, body = List.assoc (x, fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs @ attrs_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_String(_,_) ->
                    let formals, body = List.assoc ("String", fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_Bool(_) ->
                    let formals, body = List.assoc ("Bool", fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_Int(_) ->
                    let formals, body = List.assoc ("Int", fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body
            end
    | (loc,_,Divide(e1,e2)) -> 
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            let result_value = match v1, v2 with
            | _, Cool_Int(0l) -> (*XXX*) err loc "division by zero"
            | Cool_Int(i1), Cool_Int(i2) -> 
                    Cool_Int(Int32.div i1 i2)
            | _,_ -> failwith "Bad divide"
            in
            result_value, s3
    | (_,_,If(pred, thn, els)) ->
            let v1, s2 = eval so s e pred in
            begin match v1 with
            | Cool_Bool(true) ->
                    eval so s2 e thn
            | Cool_Bool(false) ->
                    eval so s2 e els
            | _ -> failwith "Non-bool predicate"
            end
    | (_,_,Integer(i)) -> Cool_Int(i), s
    | (_,_, Internal(fname)) -> 
            begin match fname with
            | "IO.out_string" ->
                    let loc = List.assoc "x" e in
                    let str = List.assoc loc s in
                    begin match str with
                    | Cool_String(str_lit, strlen) -> 
                            printf "%s" (str_format str_lit);
                    so, s
                    | _ -> failwith "Bad out_string"
                    end
            | "IO.out_int" ->
                    let loc = List.assoc "x" e in
                    let c_int = List.assoc loc s in
                    begin match c_int with
                    | Cool_Int(int_lit) -> printf "%ld" int_lit;
                    so, s
                    | _ -> failwith "Bad out_int"
                    end
            | "Object.type_name" ->
                    begin match so with
                    | Cool_Object(cname, _) -> 
                            let str = Cool_String(cname, String.length cname) in
                            str, s
                    | Cool_Bool(_) ->
                            let str = Cool_String("Bool", 4) in
                            str, s
                    | Cool_Int(_) ->
                            let str = Cool_String("Int", 3) in
                            str, s
                    | _ -> failwith "Some class without name"
                    (*
                            let str = Cool_Int("Int", 3) in
                            str, s
                            *)
                    end
            | "String.length" ->
                    begin match so with
                    | Cool_String(_,len) ->
                            let len32 = Int32.of_int len in
                            Cool_Int(len32), s
                    | _ -> failwith "String.length called from non-string"
                    end


            | _ -> failwith ("Unimplemented internal " ^ fname)
            end
    | (_,_,Plus(e1,e2)) -> 
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            let result_value = match v1, v2 with
            | Cool_Int(i1), Cool_Int(i2) -> 
                    Cool_Int(Int32.add i1 i2)
            | _,_ -> failwith "Bad plus"
            in
            result_value, s3
    | (_,_,Minus(e1,e2)) -> 
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            let result_value = match v1, v2 with
            | Cool_Int(i1), Cool_Int(i2) -> 
                    Cool_Int(Int32.sub i1 i2)
            | _,_ -> failwith "Bad minus"
            in
            result_value, s3
    (*class_map = (string * ((string * string * exp) list)) list*)
    | (_,_, New("SELF_TYPE")) -> failwith "implement New S_T"
    | (_,_, New(cname)) ->
            (* Get attributes and initializers*)
            let attrs_and_inits = List.assoc cname cm in
            (* Locations*)
            let new_attr_locs = List.map (fun (aname, atype, ainit) ->
                newloc ()
            ) attrs_and_inits in

            (* Names+Locs*)
            let attr_names = List.map (fun (aname, atype, ainit) ->
                aname) attrs_and_inits in
            let attrs_and_locs = List.combine attr_names new_attr_locs in

            (* Types+Locs*)
            let attr_types = List.map (fun (aname, atype, ainit) ->
                atype) attrs_and_inits in
            let types_and_locs = List.combine attr_types new_attr_locs in

            (* Default init and allocate for new object*)
            let v1 = Cool_Object(cname, attrs_and_locs) in
            let store_updates = List.map (fun (atype, loc) ->
                match atype with
                | "Int" -> (loc,Cool_Int(0l))
                | "String" -> (loc, Cool_String("",0))
                | "Bool" -> (loc, Cool_Bool(false))
                | _ -> (loc, Void)
            ) types_and_locs in
            let s2 = s @ store_updates in
            (* Select only init attributes*)
            let initialized_attribs = List.filter (fun triple ->
                match triple with
                | (_,_, None) -> false
                | _ -> true
            ) attrs_and_inits in
            (*TODO getting a warning about matching (_,_,None) but I thought
             * I took care of this. Tests on uninitialized attributes seem to work.*)
            let final_store = List.fold_left (fun acc_store attr ->
                match attr with
                | (_,_,None) -> failwith "attribute without init"
                | (aname, _, Some ainit) -> let _, updated_store = 
                    (*TODO make custom *init* exp to handle this. Easier debugging*)
                    eval v1 acc_store attrs_and_locs ("0", "Int", Assign(aname, ainit)) in
                updated_store
            ) s2 initialized_attribs in
            v1, final_store
    | (_,_,String(str)) -> Cool_String(str, String.length str), s
    | (_,_,Times(e1,e2)) -> 
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            let result_value = match v1, v2 with
            | Cool_Int(i1), Cool_Int(i2) -> 
                    Cool_Int(Int32.mul i1 i2)
            | _,_ -> failwith "Bad times"
            in
            result_value, s3
    | (_,_, Variable(vname)) ->
            let loc = List.assoc vname e  in
            List.assoc loc s, s
    | _ -> failwith ( sprintf "Unhandled expr type %s" (exp_to_str expr))
    (*TODO Find out why this ^ is "unused"*)
(*
Assign of string * exp
Block
Bool of bool
| Case of exp * ((string * string * exp) list)
Dispatch of (exp option) * string * (exp list)
Divide of exp * exp
| Eq of exp * exp
If of exp * exp * exp
Integer of Int32.t
- Internal of string (*Object.copy &c.*)
| Isvoid of exp
| Le of exp * exp
        (*id        type     assign?            body*)
| Let of (string * string * (exp option)) list * exp
| Loop of exp * exp
| Lt of exp * exp
Minus of exp * exp
| Neg of exp
| New of string
| Not of exp
| Plus of exp * exp
| Self
| Static of exp * string * string * (exp list)
String of string
Times of exp * exp
Variable of string
*)
    in
    debug_indent(); debug "+++++++++++\n";
    debug_indent(); debug "ret val.=%s\n" (value_to_str new_val);
    debug_indent(); debug "retstore=%s\n" (store_to_str new_store);
    indent_count := !indent_count - 2;
    new_val, new_store

let main () = begin
    let last = ("0", "Object", Dispatch( Some ("0", "Object", New("Main")), "main", [])) in
    debug "last = %s\n" (exp_to_str last);

    let init_so = Void in
    let init_store = [] in
    let init_env = [] in
    let final_val, final_store = eval init_so init_store init_env last in
    debug "result val   = %s\n" (value_to_str final_val);
    debug "result store = %s\n" (store_to_str final_store);
end;;
main();;
