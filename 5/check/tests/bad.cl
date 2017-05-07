class Main{
    main(): Object{
        let s: String <- "abcdefghij" in
            (new IO).out_string(s.substr(0, ~1))
    };
};
