(*type loc = string
type id = loc * string
type cool_type = id*)
type class_map = attrib_class list
and id = string
and loc = string
and cool_type = string (*id*)
and attrib_class = id * attrib list
and attrib = id * cool_type * (exp option)
and exp =
    | loc * exp_kind
and exp_kind =
    | Integer of int
    | String of string
(*type imp_map = imp_class list*)
(*type parent_map = sub_super list*)


let main () = begin
    let fname = Sys.argv.(1) in
    let fin = open_in fname in
    let read() =
        input_line fin (*fix for \r\n*)
    in

    let rec range k =
        if k <= 0 then
        else k :: (range (k-1))
    in

    let read_list worker =
        let k = int_of_string (read()) in
        let lst = range k in
        List.map (fun _ -> worker () ) lst
    in

    (*read attribute map*)
    let rec read_attrib_map () =
        read_list read_attrib_class

    and read_id () =
        let loc = read() in
        let name = read() in
        (loc, name)

    and read_attrib () =
        let init = match read() with
        | "no_initializer" ->
            let aname = read_id () in
            let 
        | "initializer" -> read_exp()

    and read_attrib_class () =
        let cname = read_id () in
        let attrib_list = read_list read_attrib in
        (cname, attrib_list)


end;;
main();;
