let rec fuck str =
  try
    let i = String.index str '\\' in
    if String.length str > i + 1 && str.[i+1] == 'n' then
        (String.sub str 0 i) 
        ^ "\n" 
        ^ (fuck (String.sub str (i + 2) ((String.length str) - (i + 2)) ))
    else 
        if String.length str > i + 1 && str.[i+1] == 't' then
        (String.sub str 0 i) 
        ^ "\t" 
        ^ (fuck (String.sub str (i + 2) ((String.length str) - (i + 2)) ))
        else
            str
  with Not_found -> str;;
let main () = begin
    let s = "Hello\\n world\\n" in
    let s = "H\\n\\n\\tello\\n world\\n" in
    Printf.printf "%s" (fuck s);
end;;
main();;
