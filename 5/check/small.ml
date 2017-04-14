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


    let read_first =


end;;
main();;
