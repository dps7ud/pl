Usage:
flex -o main.c pa2.lex
gcc -Wall *.c
./a.out <*.cl>

The nearby lexical analyzer was generated using flex 2.6.0 and gcc 4.1.2.
    
    The bulk of student work can be found in the pa2.lex file.

    definitions -> we make use of the following imports:
        limits.h: to have the value MAX_INT
        stdio.h:  printf and file IO
        stdlib.h: atoi, NULL, malloc &c.
        Token.c:  student file defining c tokens
        
        Apart from the above imports, we define a function to handle error output and
    a C implementation of a singly linked list.

    patterns and rules ->
        Patterns for keywords, identifiers, boolean literal and special symbols are 
    self-documenting and simple. To find integer literals, we match [0-9]+ and
    handle errors later. We similarly implement errors while scanning both strings
    and comments. Values are scanned and error checking is done in main, not yylex.
        A separate start state was used to find multi-line comments and an integer counter
    was used to allow for nested comments. Single line comments do not enter the comment
    start state as they always terminate on the next newline character. If we scan EOF while
    in the COMMENT state, we pass error -2 to the error handling mechanism.
        Strings were implemented without using a start state and a single regular expression
    was used to find string constants.

    main ->
        Each token returned was added to a list of tokens. Strings and Int literals
    were checked for a variety of errors. If an error is encountered, we immediately
    end lexing and push an error message to stdout. Otherwise, we open our file, push
    all needed information to the file and exit.


    error handling -> 
        Since we expect yylex to return one of the token_t enum values, we will instead
    return negative numbers to indicate some error state. Negative values are defined as
    follows:
        -1: scanned EOF in INITIAL state. Corresponds to regular end state.
        -2: invalid character error
        -3: EOF in (* comment *)
        -4: bad integer literal values
        -5: string constant > 1024 chars
        -6: input file is not a .cl file


    Novel positive test cases include:
        specific case sensitivity of true/false
        the empty file
        files with one token
        files empty except whitespace
        files empty except comments
        empty strings
        integers == MAX_INT
        mixed case keywords
        interaction between comment types
        nesting comments
        line comments immediately preceding EOF
        invalid programs that should be accepted by the lexer
    
    Negative test cases include:
        weird ascii control chars
        EOF in a multi-line comment
        strings with newlines
        strings with null char
        integers > MAX_INT
        testing bad characters
        problematic combinations of the characters (") and (\)
