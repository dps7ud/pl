open Printf
open A_typedefs

(* This function tracks allocation of the store*)
let new_location_counter = ref 1000
let newloc () =
    incr new_location_counter ;
    !new_location_counter 

(***************************)
(** Debugging and Tracing **)
(***************************)
    (*
let do_debug = ref false
let debug fmt=
    let handle result_string =
        if !do_debug then printf "%s" result_string
    in
    kprintf handle fmt
    *)

(* This function constructs a string representing a cool expression*)
let rec exp_to_str expr =
    match expr with
    | (_,_,Assign(x, e)) -> sprintf "Assign(%s, %s)" x (exp_to_str e)
    | (_,_,Block(explist)) ->
            let exp_str = List.fold_left (fun acc elt ->
                acc ^ ", " ^ (exp_to_str elt)
            ) "" explist in
            sprintf "Block([%s])" exp_str
    | (_,_,Bool(b)) -> sprintf "Bool(%b)" b
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
    | (_,_,Eq(e1, e2)) -> sprintf "Eq(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,If(a,b,c)) -> sprintf "If(%s,%s,%s)" (exp_to_str a) (exp_to_str b) (exp_to_str c)
    | (_,_,Integer(i)) -> sprintf "Integer(%ld)" i
    | (_,_,Internal(s)) -> sprintf "Internal(%s)" s
    | (_,_,Isvoid(e)) -> sprintf "Isvoid(%s)" (exp_to_str e)
    | (_,_,Le(e1, e2)) -> sprintf "Le(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,Let(bind_list, body)) ->
            let bind_string = List.fold_left (fun acc elt ->
                begin match elt with
                | (name, tipe, None) -> acc ^ name ^ ":" ^ tipe ^ ", "
                | (name, tipe, Some value) -> 
                        acc ^ name ^ ":" ^ tipe ^ "<-" ^ (exp_to_str value) ^ ", "
                end
            ) "" bind_list in
            sprintf "Let([%s], %s" bind_string (exp_to_str body)
    | (_,_,Loop(e1, e2)) -> sprintf "Loop(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,Lt(e1, e2)) -> sprintf "Lt(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,Minus(e1, e2)) -> sprintf "Minus(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,Neg(e1)) -> sprintf "Neg(%s)" (exp_to_str e1)
    | (_,_,New(s)) -> sprintf "New(%s)" s
    | (_,_,Not(e1)) -> sprintf "Not(%s)" (exp_to_str e1)
    | (_,_,Plus(e1, e2)) -> sprintf "Plus(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,Self) -> sprintf "Self"
    | (_,_,String(s)) -> sprintf "String(\"%s\")" s
    | (_,_,Static(caller, at_type, mname, args)) ->
            let arg_str = List.fold_left (fun acc elt ->
                acc ^ ", " ^ (exp_to_str elt)
            ) "" args in
            (* "" (List.map (fun (_,_,e) -> e) args) in*)
            sprintf "Static(%s, %s, %s, [%s])" (exp_to_str caller) at_type mname arg_str
    | (_,_,Times(e1, e2)) -> sprintf "Times(%s, %s)" (exp_to_str e1) (exp_to_str e2)
    | (_,_,Variable(x)) -> sprintf "Variable(%s)" x

(* This function constructs a string representing a cool value*)
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

(* This function constructs a string representing a cool environment*)
let env_to_str env =
    let binding_str = List.fold_left (fun acc (aname, aaddr) ->
        sprintf "%s, %s=%d" acc aname aaddr
    ) "" (List.sort compare env) in
    sprintf "[%s]" binding_str

(* This function constructs a string representing a cool store*)
let store_to_str store_in =
    let store_str = List.fold_left (fun acc (addr, cvalue) ->
        sprintf "%s, %d=%s" acc addr (value_to_str cvalue)
    ) "" (List.sort compare store_in) in
    sprintf "[%s]" store_str

(*
let indent_count = ref 0
let debug_indent () =
    debug "%s" (String.make !indent_count ' ')
    *)
(*Here, we desearialize the needed maps*)
let cm = Deserialize.read_class_map ()
let im = Deserialize.read_imp_map ()
let pm = Deserialize.read_parent_map ();;



(**********************)
(** Helper functions **)
(**********************)

(* This function formats strings for printing in accordance
 * with cool standards*)
let rec str_format str =
  try
    let i = String.index str '\\' in
    if String.length str = 0 then
        str
    else
        if String.length str > i + 1 && str.[i+1] == 'n' then
            let first = (String.sub str 0 i) in
            first
            ^ "\n" 
            ^ (str_format (String.sub str (i + 2) ((String.length str) - (i + 2)) ))
        else 
            if String.length str > i + 1 && str.[i+1] == 't' then
            (String.sub str 0 i) 
            ^ "\t"
            ^ (str_format (String.sub str (i + 2) ((String.length str) - (i + 2)) ))
            else
                String.sub str 0 (i + 1) 
                ^ (str_format (String.sub str (i+1) (String.length str - (i+1))  ) )
  with Not_found -> str;;

(* Puts error message and linenumber to stdout and halts execution*)
let err linum msg =
    printf "ERROR: %s: Exception: %s\n" linum msg;
    exit 1

(* Gets default value for passed cool type*)
let get_default type_str =
    match type_str with
    | "Int" -> Cool_Int(0l)
    | "String" -> Cool_String("",0)
    | "Bool" -> Cool_Bool(false)
    | _ -> Void

(* Calculates closest *)
let rec get_closest etype options =
    if List.mem etype options then
        etype
    else
        (* Not_found is allowed to pass up to eval
         * and this is caught to determine an unhandled
         * case branch*)
        let next_type = List.assoc etype pm in
        get_closest next_type options

(* These are used to read input ints*)
let whitespace = [' '; '\n'; '\r'; '\011'; '\012'; '\t']
let numeric = ['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '0']

(* Left string a given string*)
let rec strip_left in_string =
    match in_string with
    | "" -> ""
    | s ->
            let c = String.get s 0 in
            if List.mem c whitespace then
                strip_left (String.sub s 1 (String.length s -1))
            else
                s

(* Will return the last digit character of the given string*)
let rec get_last_numeric in_string index =
    match in_string with
    | "" -> index
    | in_string ->
            let c = String.get in_string 0 in
            if List.mem c numeric then
                get_last_numeric (String.sub in_string 1 (String.length in_string -1)) (index + 1)
            else
                index

(* Will allow a single leading minus sign*)
let as_int in_string =
    match in_string with
    | "" -> 0
    | non_empty ->
            begin match String.get non_empty 0 with
            | '-' -> get_last_numeric (String.sub non_empty 1 (String.length non_empty -1)) 1
            | _ -> get_last_numeric non_empty 0
            end

(* Using the above functions, parse input string to an integer
 * as specified in the CRM*)
let handle_int base_str =
    let trimmed = strip_left base_str in
    let last_index = as_int trimmed in
    if last_index = 0 then 
        0
    else
        let good_str = String.sub trimmed 0 last_index in
        let good_int = 
            try
            int_of_string good_str
            with int_of_string -> 0
        in
        if good_int > 2147483647 || good_int < -2147483648 then
            0
        else
            good_int


(* Stack frame counter*)
let stack_frames = ref 0

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
    (*
    indent_count := !indent_count + 2;
    debug "\n";
    debug_indent () ; debug "eval.:%s\n" (exp_to_str expr);
    debug_indent () ; debug "so...=%s\n" (value_to_str so);
    debug_indent () ; debug "store=%s\n" (store_to_str s);
    debug_indent () ; debug "env..=%s\n" (env_to_str e);
    *)
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
    | (linno, _, Case(e0, case_list)) ->
            let v1, s2 = eval so s e e0 in
            let options = List.map (fun case_elem ->
                begin match case_elem with
                | (_, type_only,_) -> type_only
                end
            ) case_list
            in
            let branch_type = try 
                begin match v1 with
                | Void -> err linno "case on void"
                | Cool_Int(i) -> get_closest "Int" options
                | Cool_String(s, len) -> get_closest "String" options
                | Cool_Bool(b) -> get_closest "Bool" options
                | Cool_Object(cname, atters_and_locs) -> get_closest cname options
                end 
            with Not_found -> 
                (* If this error is raised, we have a unmatched case expression*)
                err linno ("case without matching branch: " ^ (value_to_str v1))
            in
            let branch = (List.filter (fun elem -> 
                begin match elem with
                | (_,name,_) -> name = branch_type
                end
            ) case_list)
            in
            let branch = List.hd branch in
            begin match branch with
            | (id, branch_type, branch_exp) ->
                    let loc = newloc () in
                    let s3 = [(loc, v1)] @ s2 in
                    let env = [(id, loc)] @ e in
                    eval so s3 env branch_exp
            end
    | (linno,_, Dispatch(e0, fname, args)) ->
            incr stack_frames;
            if !stack_frames > 1000 then
                err linno "stack overflow";
            let current_store = ref s in
            let arg_values = List.map (fun arg_exp ->
                let arg_value, new_store = eval so !current_store e arg_exp in
                current_store := new_store;
                arg_value
            ) args in
            let v0, s_n2 = begin match e0 with
            (* Either evaluate calling expr*)
            | Some e0 -> eval so !current_store e e0
            (* Or it's self dispatch and use so*)
            | None -> so, !current_store
            end in
            let final_val, final_store = begin match v0 with
            | Void -> err linno "dispatch on void"

            | Cool_Object (x, attrs_and_locs) ->
                    let formals, body = List.assoc (x, fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        let i = newloc() in
                        i
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
(*                    let s_n3 = store_update @ s_n2 in*)
                    let s_n3 = List.rev_append store_update s_n2 in
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
            in
            decr stack_frames;
            final_val, final_store
    | (linno,_,Divide(e1,e2)) -> 
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            let result_value = match v1, v2 with
            | _, Cool_Int(0l) -> err linno "division by zero"
            | Cool_Int(i1), Cool_Int(i2) -> 
                    Cool_Int(Int32.div i1 i2)
            | _,_ -> failwith "Bad divide"
            in
            result_value, s3
    | (_,_,Eq(e1, e2)) ->
        let v0, s2 = eval so s e e1 in
        let v1, s3 = eval so s2 e e2 in
        begin match v0, v1 with
        | Void, Void -> Cool_Bool(true), s3
        | Cool_Int(i1), Cool_Int(i2) -> Cool_Bool((Int32.sub i1 i2) = Int32.zero), s3
        | Cool_Bool(b1), Cool_Bool(b2) -> Cool_Bool(b1 = b2), s3
        | Cool_String(s1, l1), Cool_String(s2, l2) -> Cool_Bool(s1 = s2), s3
        | a, b -> Cool_Bool(a == b), s3
        end
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
    | (lineno,_, Internal(fname)) -> 
            begin match fname with
            | "IO.in_int" ->
                    let oc_str =
                        try
                            let x = read_line () in
                            x
                        with 
                            End_of_file -> "0";
                    in
                    let x = handle_int oc_str in
                    Cool_Int(Int32.of_int x), s
            | "IO.in_string" ->
                    let null_char = '\x00' in
                    let oc_str =
                        try
                            let x = read_line () in
                            x
                        with 
                            End_of_file -> "";
                    in
                    if String.contains oc_str null_char then
                        Cool_String("", 0), s
                    else
                        Cool_String(oc_str, String.length oc_str), s
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
                    | Cool_Int(int_lit) -> 
                            printf "%ld" int_lit; 
(*                            if !do_debug then flush stdout;*)
                            so, s
                    | _ -> failwith "Bad out_int"
                    end
            | "Object.abort" ->
                    let abort = "abort" in
                    printf "%s\n" abort;
                    exit 0;
                    Void, s
            | "Object.copy" ->
                    let so_copy = begin match so with
                    | Cool_Bool(b) -> Cool_Bool(b)
                    | Cool_Int(i) -> Cool_Int(i)
                    | Cool_String(s, len) -> Cool_String(s, len)
                    | Void -> failwith "Copy of void"
                    | Cool_Object(cname, attrs_and_locs) -> 
                            Cool_Object(cname, attrs_and_locs)
                    end in
                    so_copy, s
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
                    | Cool_String(_) ->
                            let str = Cool_String("String", 6) in
                            str, s
                    | Void -> failwith "Name of void"
                    end

            | "String.length" ->
                    begin match so with
                    | Cool_String(_,len) ->
                            let len32 = Int32.of_int len in
                            Cool_Int(len32), s
                    | _ -> failwith "String.length called from non-string"
                    end
            | "String.substr" ->
                    begin match so with
                    | Cool_String(str, len) ->
                            let ci1 = (List.assoc (List.assoc "i" e) s) in
                            let ci2 = (List.assoc (List.assoc "l" e) s) in
                            begin match ci1, ci2 with
                            | Cool_Int(li1), Cool_Int(li2) ->
                                    let i1 = int_of_string (Int32.to_string li1) in
                                    let i2 = int_of_string (Int32.to_string li2) in
                                        if (i1 + i2 > len) || i2 < 0 || i1 < 0 then
                                            err lineno "String.substr out of range"
                                        else
                                            Cool_String (String.sub str i1 i2, i2), s
                            | _ -> failwith "Non-int arg to substr"
                            end
                    | _ -> failwith "String.length called from non-string"
                    end
            | "String.concat" ->
                    begin match so with
                    |Cool_String(str1, len1) ->
                            let loc = List.assoc "s" e in
                            let to_concat = List.assoc loc s in
                            begin match to_concat with
                            | Cool_String(str2, len2) ->
                                    Cool_String(str1 ^ str2, len1 + len2), s
                            | _ -> failwith "Argument for concat not a string"
                            end
                    | _ -> failwith "String.concat called from non-string"
                    end
            | _ -> failwith ("Unimplemented internal " ^ fname)
            end
    | (_,_,Isvoid(e1)) ->
            let v0, s2 = eval so s e e1 in
            begin match v0 with
            | Void -> Cool_Bool(true), s2
            | _ -> Cool_Bool(false), s2
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
    | (_,_,Le(e1,e2)) ->
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            begin match v1, v2 with
            | Void, Void -> Cool_Bool(true), s3
            | Cool_Int(i1), Cool_Int(i2) -> Cool_Bool(i1 <= i2), s3
            | Cool_String(s1,l1), Cool_String(s2,l2) -> Cool_Bool(s1 <= s2), s3
            | Cool_Bool(b1), Cool_Bool(b2) -> Cool_Bool(b1 <= b2), s3
            | v1, v2 -> Cool_Bool(v1 == v2), s3
            end
             (*id      type     assign?             body*)
(*  | Let of (string * string * (exp option)) list * exp*)
    | (lino, etype, Let(binding_list, body)) ->
            begin match binding_list with
            | [] ->
                    let body_val, bad_store = eval so s e body in
                    body_val, bad_store
            | _  ->
                    let ident, bind_type, assign  = List.hd binding_list in
                    let loc = newloc () in
                    let s2 = [(loc, get_default bind_type)] @ s in
                    let e2 = [(ident, loc)] @ e in
                    begin match assign with
                    | Some assign ->
                            let v1, s3 = eval so s2 e2 assign in
                            let s4 = (loc, v1) :: List.remove_assoc loc s3 in
                            let new_expr = (lino, etype, Let(List.tl binding_list, body)) in
                            let v2, s5 = eval so s4 e2 new_expr in
                            v2, s5
                    | None ->
                            let new_expr = (lino, etype, Let(List.tl binding_list, body)) in
                            let v2, s5 = eval so s2 e2 new_expr in
                            v2, s5
                    end
            end

    | (linno, etype, Loop(pred, body)) ->
            let v0, s1 = eval so s e pred in
            begin match v0 with
            | Cool_Bool(false) -> Void, s1
            | Cool_Bool(true) ->
                    let v1, s2 = eval so s1 e body in
                    let newexpr = (linno, etype, Loop(pred, body)) in
                    eval so s2 e newexpr
            | _ -> failwith "Non-bool loop predicate"
            end

    | (_,_,Lt(e1,e2)) ->
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            begin match v1, v2 with
            | Cool_Int(i1), Cool_Int(i2) -> Cool_Bool(i1 < i2), s3
            | Cool_String(s1,l1), Cool_String(s2,l2) -> Cool_Bool(s1 < s2), s3
            | Cool_Bool(b1), Cool_Bool(b2) -> Cool_Bool(b1 < b2), s3
            | _ -> Cool_Bool(false), s3
            end
    | (_,_,Minus(e1,e2)) -> 
            let v1, s2 = eval so s e e1 in
            let v2, s3 = eval so s2 e e2 in
            let result_value = 
                begin match v1, v2 with
                | Cool_Int(i1), Cool_Int(i2) -> 
                        Cool_Int(Int32.sub i1 i2)
                | _,_ -> failwith "Bad minus"
                end
            in
            result_value, s3
    | (_,_, Neg(e1)) ->
            let v1, s2 = eval so s e e1 in
            begin match v1 with
            | Cool_Int(i) -> Cool_Int(Int32.neg i), s2
            | _ -> failwith "Non-integral negation"
            end
    | (linno, etype, New("SELF_TYPE")) ->
            begin match so with
            | Cool_Object(cname, _) ->
                    let newexp = (linno, etype, New(cname)) in
                    eval so s e newexp
            | _ -> failwith "Non-object SELF_TYPE -- I don't think this can happen"
            end
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
            let final_store = List.fold_left (fun acc_store attr ->
                match attr with
                | (_,_,None) -> failwith "attribute without init"
                | (aname, _, Some ainit) -> let _, updated_store = 
                    (*TODO make custom *init* exp to handle this. Easier debugging*)
                    eval v1 acc_store attrs_and_locs ("0", "Int", Assign(aname, ainit)) in
                updated_store
            ) s2 initialized_attribs in
            v1, final_store
    | (_,_, Not(e1)) ->
            let v1, s2 = eval so s e e1 in
            begin match v1 with
            | Cool_Bool(false) -> Cool_Bool(true), s2
            | Cool_Bool(true) -> Cool_Bool(false), s2
            | _ -> failwith "Non-bool 'not'"
            end
    | (_,_,Self) -> so, s
    | (linno,_,Static(caller, stat, fname, args)) ->
            incr stack_frames;
            let current_store = ref s in
            let arg_values = List.map (fun arg_exp ->
                let arg_value, new_store = eval so !current_store e arg_exp in
                current_store := new_store;
                arg_value
            ) args in
            let v0, s_n2 = eval so !current_store e caller in
            let result = begin match v0 with
            | Void -> err linno "static dispatch on void"

            | Cool_Object (x, attrs_and_locs) ->
                    let formals, body = List.assoc (stat, fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs @ attrs_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_String(_,_) ->
                    let formals, body = List.assoc (stat, fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_Bool(_) ->
                    let formals, body = List.assoc (stat, fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body

            | Cool_Int(_) ->
                    let formals, body = List.assoc (stat, fname) im in
                    let new_arg_locs = List.map (fun arg_exp ->
                        newloc()
                    ) args in
                    let formals_and_locs = List.combine formals new_arg_locs in
                    let store_update = List.combine new_arg_locs arg_values in
                    let s_n3 = store_update @ s_n2 in
                    let inner_env = formals_and_locs in
                    eval v0 s_n3 inner_env body
            end
            in
            decr stack_frames;
            result
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
            begin match vname with
            | "self" -> so, s
            | _ ->
                let loc = List.assoc vname e  in
                List.assoc loc s, s
            end
    in
    (*
    debug_indent(); debug "+++++++++++\n";
    debug_indent(); debug "ret val.=%s\n" (value_to_str new_val);
    debug_indent(); debug "retstore=%s\n" (store_to_str new_store);
    indent_count := !indent_count - 2;
    *)
    new_val, new_store

(*****************)
(** Entry point **)
(*****************)
let main () = begin
    (* Running the input program is identically 
     * evaluation of the below expression *)
    let last = ("0", "Object", Dispatch( Some ("0", "Object", New("Main")), "main", [])) in
    let init_so = Void in
    let init_store = [] in
    let init_env = [] in
    eval init_so init_store init_env last
end;;
main(
);;
