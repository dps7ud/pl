#include <limits.h>
#include <stdio.h>
/*
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
*/

enum token_t{
    AT,
    IN,
    IF,
    CLASS,
    ELSE
};


enum token_t func(){
    return CLASS;
}

int main(){
    enum token_t tok = func();
    printf("%d  %d\n",(int)CLASS, (int)tok);
    printf("%d  %d\n",CLASS < -1, tok < -1);
    printf("tok < 0:%d  tok > 1:%d\n",tok < 0, tok > 1);
    printf("tok <-1:%d  tok > 1:%d\n",tok < -1, tok > 1);
    printf("%d\n", INT_MAX);
    return 0;
}
