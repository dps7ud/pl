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
(*
type imp_map = imp_class list
and imp_class = id * cool_method list
and cool_method = 
    *)
(*type parent_map = sub_super list*)


let main () = begin
    let fname = Sys.argv.(1) in
    let fin = open_in fname in
    let read() =
        input_line fin (*fix for \r\n*)
    in

    let rec range k =
        if k <= 0 then []
        else k :: (range (k-1))
    in

    let read_list worker =
        let k = int_of_string (read()) in
        let lst = range k in
        List.map (fun _ -> worker () ) lst
    in

    (*read attribute map*)
    let rec read_class_map () =
        read() ;
        read_list read_attrib_class
       

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
        let c_type = read() in
        match read () with
            | "integer" -> 
                    let ival = int_of_string (read ()) in
                    (loc, c_type, Integer ival)
            | "string" ->
                    let sval = read() in
                    (loc, c_type, String sval)
            | x -> failwith ("Unhandled exp kind: " ^ x)
    in

    let cm = read_class_map () in
    close_in fin ;
    printf "CM deserialized: %d classes\n" (List.length cm)



end;;
main();;
