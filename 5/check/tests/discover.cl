class Main inherits IO{
    one: A <- new A;
    two: A <- new A;
    main(): Object{{
        if one < two then
            out_string("one < two\n")
        else
            out_string("one >= two\n")
        fi;

        if one <= two then
            out_string("one <= two\n")
        else
            out_string("one > two\n")
        fi;

        if two < one then
            out_string("two < one\n")
        else
            out_string("two >= one\n")
        fi;

        if two <= one then
            out_string("two <= one\n")
        else
            out_string("two > one\n")
        fi;
    }};
};

class A{};
