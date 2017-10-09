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

/* Making use of pre-processor to handle enum code was largely borrowed from
 * a stackoverflow post. See references.txt.
 */
