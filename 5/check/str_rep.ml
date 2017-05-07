let rec str_format str =
  try
    let i = String.index str '\\' in
    if String.length str = 0 then
        str
    else
        if String.length str > i + 1 && str.[i+1] == 'n' then
            let first = (String.sub str 0 i) in
            Printf.printf "%s\n" first;
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

let main () = begin
    let s = "Hello\\n world\\n" in
    let s = "H\\n\\n\\tello\\n world\\n" in
    let x = "A glooming \\n\n\npeace this morning with it brings" in
    let x = read_line () in
    Printf.printf "%s" (str_format x);
(*    Printf.printf "%d\n" i;*)
(*    Printf.printf "%s" (fuck s);*)
(*    Printf.printf "%s" (str_format s);*)
end;;
main();;

