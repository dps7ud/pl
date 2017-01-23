let lines = ref [] in
try
    while true do
        lines := (read_line()) :: !lines
    done
with _ -> begin
    let lst = !lines in
    List.iter print_endline lst
end
