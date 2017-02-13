%x COMMENT
%{

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

#include "Token.c"

int numLines = 0;
int commentDepth = 0;

void throwError(int lineNumber, int errorCode, char* badInput){
    switch(errorCode){
        case -2:
            printf("ERROR: %d Lexer: invalid character %c\n", lineNumber, badInput[0]);
            break;
        case -3:
            printf("ERROR: %d Lexer: EOF in (* comment *)\n", lineNumber);
            break;
        case -4:
            printf("ERROR: %d Lexer: not a non-negitive 32-bit signed integer:%s\n" \
                , lineNumber, badInput);
            break;
    }
}

struct node {
    char * head;
    char * val;
    int lino;
    struct node * next;
} ;

%}
%%
\ |\t|\f|\v //Ignore whitespace that isn't newline
(?i:case)   return CASE;
(?i:else) return ELSE;

(?i:class)  return CLASS;
(?i:esac)   return ESAC;
f(?i:alse) return FALSE;
(?i:fi) return FI;
(?i:if) return IF;
(?i:in) return IN;
(?i:inherits) return INHERITS;
(?i:isvoid) return ISVOID;
(?i:let)    return LET;
(?i:loop)   return LOOP;
(?i:new)    return NEW;
(?i:not)    return NOT;
(?i:of)     return OF;
(?i:pool)   return POOL;
(?i:then)   return THEN;
t(?i:rue)  return TRUE;
(?i:while)  return WHILE;
\"(\\[^\n\0<<EOF>>]|[^\n\"\0<<EOF>>])*\"      return STRING;

<COMMENT,INITIAL>\-\-.*              // ignore singe-line comments
<COMMENT,INITIAL>(\n|\n\r|\r\n|\r)  ++numLines;
<COMMENT>\*\) {   // End comment
                    commentDepth--;
                    if(commentDepth == 0){
                        BEGIN(INITIAL);
                    }
                }
<COMMENT><<EOF>>          return -3;
<COMMENT>\*               // Consume stars in comments
<COMMENT>[^*]             // Consume anything not a star
<INITIAL,COMMENT>\(\* {   // Begin comment
                            commentDepth++;
                            BEGIN(COMMENT);
                        }

@    return AT;
:    return COLON;
,    return COMMA;
\/   return DIVIDE;
\.   return DOT;
=    return EQUALS;
\<\- return LARROW;
\<\= return LE;
\{   return LBRACE;
\(   return LPAREN;
\<   return LT;
\-   return MINUS;
\+   return PLUS;
\=\> return RARROW;
\}   return RBRACE;
\)   return RPAREN;
;    return SEMI;
\~   return TILDE;
\*   return TIMES;


[a-z][a-zA-Z0-9_]*      return IDENTIFIER;
[A-Z][a-zA-Z0-9_]*      return TYPE;
[0-9]+                  return INTEGER;
.                       return -2;// Invalid character
<<EOF>>                 return -1;

%%

int main(int argc, char **argv){
// \"(\\[^\n\0<<EOF>>]|[^\n\"\0<<EOF>>])*\"      return STRING;
    /* error - error number or zero
    *  inName - filename passed to the lexer
    *  outName - generated filename
    *  tok - will hold each token type as it is lexed
    *  tokens - list head to which we will add
    *  yyin - global that defines input source
    */
    int error = 0;
    char* inName = argv[1];
    char outName[80];
    FILE* outFile;
    enum token_t tok;
    struct node * tokens = NULL;
    extern FILE* yyin;

    /* Set input source.*/
    yyin = fopen(inName, "r");

    /* Lex till break at end of file or error.*/
    while(1){
        /* strVal - value of regex match
         * ii - loop variable
         * newNode - Construct a node for each token
        */
        int ii;
        struct node * newNode;
        char* strVal;
        char* tokVal;

        tok = yylex();
        /* (int)tok values < -1 indicate errors.*/
        error = (int)tok;

        /* For ints, make sure values are < MAX_INT*/
        if((int)tok == 16){
            long int literalInt = strtol(strdup(yytext), 0, 10);
            if(literalInt < 0 || literalInt > 2147483647){
                error = -4;
            }
        }

        /* error == -1 EOF scanned
         * error <  -1 scanner error.
         */ 
        if(error < 0){
            break;
        }

        /* Get value of token tolower*/
        tokVal = strdup(TOKEN_STRING[tok]);
        for(ii=0; tokVal[ii]; ii++){
            tokVal[ii] += 32;
        }
        /* Get value of match. If we have a string, manualy trim quotes*/
        strVal = strdup(yytext);
        if((int)tok == 35){
            int len = strlen(strVal);
            strVal[len - 1] = 0;
            strVal += 1;
        }

        /* Create and populate our new node & push to list*/
        newNode = malloc(sizeof(*newNode));
        newNode -> head = tokVal;
        newNode -> lino = numLines + 1;
        newNode -> val = strVal;
        newNode -> next = tokens;
        tokens = newNode;
//        printf("token: %s\tnumber: %d\tval:%s\n", tokens->head, (int)tok, strVal);
    }

    /* Check for errors*/
    if(error < -1){
        throwError(numLines, error, strdup(yytext));
        return error;
    } else {
        /* Nodes for reversing our list*/
        struct node * end = NULL;
        struct node * keeper = tokens -> next;
        /*  Reverse our list.*/
        while(keeper != NULL){
            tokens -> next = end;
            end = tokens;
            tokens = keeper;
            keeper = keeper -> next;
        }
        tokens -> next = end;
        /* Generate output filename and actual file object,
         * open output file and write all our info.
        */
        strcpy(outName, argv[1]);
        strcat(outName, "-lex1");
        outFile = fopen(outName, "w");
        for(; tokens != NULL; tokens = tokens -> next){
            fprintf(outFile, "%d\n", tokens->lino);
            fprintf(outFile, "%s\n", tokens->head);
//            printf("%d\n", tokens->lino);
//            printf("%s\n", tokens->head);
            if(!(strcmp(tokens -> head, "identifier") &&
                strcmp(tokens -> head, "integer") &&
                strcmp(tokens -> head, "string") &&
                strcmp(tokens -> head, "type")) ){
//                printf("%s\n", tokens->val);
                fprintf(outFile, "%s\n", tokens->val);
            }
        }
        /* You BETTER close that file.*/
        fclose(outFile);
    }
    return 0;
}
