open Printf

let file = "hello.cl-type"

let read_file in_stream = function
    read_class_map in_stream



let () =
    let ic = open_in file in
    try
        let line = input_line ic in
        print_endline line;
        flush stdout;
        close_in ic
    with e ->
        close_in_noerr ic;
        raise e
