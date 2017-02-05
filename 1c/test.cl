Class Main inherits IO{
    main() : Object{
        {
        out_string( (new Empty).get_head() );
--        let ii : Int <- 5
--        in{
--            if ii = 5 then
--                out_string("Yes\n")
--            else
--                true
--            fi;
--        };
        }
    };
};

Class Empty {
    get_head() : String {
        let result : String <- "" in{
            result;
        }
    };
};
