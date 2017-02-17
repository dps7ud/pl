#include <stdio.h>
#define FOREACH_TOKEN(TOKEN) \
    TOKEN(AT)         \
    TOKEN(CASE)       \
    TOKEN(CLASS)      \
    TOKEN(COLON)      \
    TOKEN(COMMA)      \
    TOKEN(DIVIDE)     \
    TOKEN(DOT)        \
    TOKEN(ELSE)       \
    TOKEN(EQUALS)     \
    TOKEN(ESAC)       \
    TOKEN(FALSE)      \
    TOKEN(FI)         \
    TOKEN(IDENTIFIER) \
    TOKEN(IF)         \
    TOKEN(IN)         \
    TOKEN(INHERITS)   \
    TOKEN(INTEGER)    \
    TOKEN(ISVOID)     \
    TOKEN(LARROW)     \
    TOKEN(LBRACE)     \
    TOKEN(LE)         \
    TOKEN(LET)        \
    TOKEN(LOOP)       \
    TOKEN(LPAREN)     \
    TOKEN(LT)         \
    TOKEN(MINUS)      \
    TOKEN(NEW)        \
    TOKEN(NOT)        \
    TOKEN(OF)         \
    TOKEN(PLUS)       \
    TOKEN(POOL)       \
    TOKEN(RARROW)     \
    TOKEN(RBRACE)     \
    TOKEN(RPAREN)     \
    TOKEN(SEMI)       \
    TOKEN(STRING)     \
    TOKEN(THEN)       \
    TOKEN(TILDE)      \
    TOKEN(TIMES)      \
    TOKEN(TRUE)       \
    TOKEN(TYPE)       \
    TOKEN(WHILE)      

#define GENERATE_ENUM(ENUM) ENUM,
#define GENERATE_STRING(STRING) #STRING,

enum token_t{
    FOREACH_TOKEN(GENERATE_ENUM)
};

static char *TOKEN_STRING[] = {
    FOREACH_TOKEN(GENERATE_STRING)
};

//int main(){
//    int ii;
//    for(ii = 0; ii < 10; ii++){
//        enum token_t tok = ii;
//        printf("%s\n", TOKEN_STRING[tok]);
//    }
//}

//enum token_t{
//    //Keywords
//    CASE,
//    CLASS,
//    ELSE,
//    ESAC,
//    FALSE,
//    FI,
//    IF,
//    IN,
//    INHERITS,
//    ISVOID,
//    LET,
//    LOOP,
//    NEW,
//    NOT,
//    OF,
//    POOL,
//    THEN,
//    TRUE,
//    WHILE,
//    //Punctuation
//    AT,
//    COLON,
//    COMMA,
//    DIVIDE,
//    DOT,
//    EQUALS,
//    LARROW,
//    LBRACE,
//    LE,
//    LPAREN,
//    LT,
//    MINUS,
//    PLUS,
//    RARROW,
//    RBRACE,
//    RPAREN,
//    SEMI,
//    TILDE,
//    TIMES,
//    //Literals, type and identifier
//    IDENTIFIER,
//    INTEGER,
//    STRING,
//    TYPE
//};
/*
int main(){
    enum token_t myTok = CLASS;
    switch(myTok) {
        case CLASS: puts("class"); break;
        case IF: puts("if"); break;
        case FI: puts("fi"); break;
    }
}
*/
