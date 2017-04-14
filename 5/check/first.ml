open Printf
type class_map = attrib_class list
and id = string
and loc = string
and cool_type = string (*id*)
and attrib_class = id * attrib list
and attrib = id * cool_type * (exp option)
and exp = loc * cool_type * exp_kind
and exp_kind =
    | Integer of int
    | String of string
    | Internal of string (*Object.copy &c.*)
type imp_map = imp_class list
and imp_class = id * cool_method list
and cool_method =  id * formal list * id * exp (*class, flist, defining class, body*)
and formal = string

type parent_map = sub_super list
and sub_super = id * id (*child, parent*)


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

    (*read attribute map*)
    let rec read_class_map () =
        read() ;
        read_list read_attrib_class

    and read_imp_map () =
        read() ;
        read_list read_imp_class

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
                    let ival = int_of_string (temp(*read ()*)) in
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

end;;
main();;
