class Main inherits IO{
    s1: String <- "34;";
    s2: String <- "";
    s3: String <- "\n";
    s4: String <- "\t";
    s5: String <- "\N";
    s6: String <- "\"";
    s7: String <- "294y";
    s8: String <- "asldfkh";
    s9: String <- "\\";
    s0: String <- "a23t2";
    sa: String <- "!@#$%^&*()";
    sb: String <- "{}[]{]][}[}{";
    sc: String <- "||\\|{]\"";
    sd: String <- "}}|";
    se: String <- "ls";
    i: Int <- 10;
    main() : Object{
        while 0 < i loop {
            s1.concat(s2);
            s1 <- s1.concat(s2);
            s2 <- s2.concat(s3);
            s3 <- s3.concat(s4);
            s4 <- s4.concat(s5);
            s5 <- s5.concat(s6);
            s6 <- s6.concat(s7);
            s7 <- s7.concat(s8);
            s8 <- s8.concat(s9);
            s9 <- s9.concat(s0);
            s0 <- s0.concat(sa);
            sa <- sa.concat(sb);
            sb <- sb.concat(sc);
            sc <- sc.concat(sd);
            sd <- sd.concat(se);
            se <- se.concat("");
            i <- i - 1;
            put();
        } pool
    };
    put(): Object{
        {
        out_string(s1);
        out_string("\n");
        out_string(s2);
        out_string("\n");
        out_string(s3);
        out_string("\n");
        out_string(s4);
        out_string("\n");
        out_string(s5);
        out_string("\n");
        out_string(s6);
        out_string("\n");
        out_string(s7);
        out_string("\n");
        out_string(s8);
        out_string("\n");
        out_string(s9);
        out_string("\n");
        out_string(s0);
        out_string("\n");
        out_string(sa);
        out_string("\n");
        out_string(sb);
        out_string("\n");
        out_string(sc);
        out_string("\n");
        out_string(sd);
        out_string("\n");
        out_string(se);
        out_string("\n");
        }
    };
};
