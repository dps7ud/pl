class Main inherits IO{
    main() : Object {
        let i: Int, s: String, b: Bool in
            if i = 0 then
                if s = "" then
                    if not b then
                        out_string("A\n")
                    else
                        out_string("B\n")
                    fi
                else
                    out_string("C\n")
                fi
            else
                out_string("D\n")
            fi
    };
};
