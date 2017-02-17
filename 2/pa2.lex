%option noyywrap
%x COMMENT
%{
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include "Token.c"

int numLines = 0;
int commentDepth = 0;


void throwError(int lineNumber, int errorCode, char* badInput, int len){
    switch(errorCode){
        case -2:
            printf("ERROR: %d: Lexer: +invalid character: %c\n", lineNumber + 1, badInput[0]);
            break;
        case -3:
            printf("ERROR: %d: Lexer: +EOF in (* comment *)\n", lineNumber + 1);
            break;
        case -4:
            printf("ERROR: %d: Lexer: +not a non-negitive 32-bit signed integer: %s\n" \
                , lineNumber + 1, badInput);
            break;
        case -5:
            printf("ERROR: %d: Lexer: +string constant is too long (%d > 1024)\n"\
                , lineNumber + 1, (int)strlen(badInput) - 2);
            break;
        case -6:
            printf("Not a valid cool file\n");
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


\"(\\[^\n\0]|[^\n\"\0])*\"      return STRING;//TODO: handles \0 in string literal?

<INITIAL>\-\-.*              // ignore singe-line comments
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
<INITIAL><<EOF>>                 return -1;

%%

int main(int argc, char **argv){
    /* error - error number or zero
    *  inName - filename passed to the lexer
    *  numTokens - number of tokens lexed
    *  outName - generated filename
    *  outFile - FILE* to output file
    *  tok - will hold each token type as it is lexed
    *  tokens - list head to which we will add
    *  yyin - global that defines input source
    */
    int error = 0;
    char* inName = argv[1];
    int numTokens = 0;
    char outName[80];
    FILE* outFile;
    enum token_t tok;
    struct node * tokens = NULL;
    extern FILE* yyin;

    /* Here we check if the input file is not a .cl file.*/
    if(argc > 1){
        int len = strlen(inName);
        if(len < 4){
            throwError(0, -6, inName, (char)65);
            return 0;
        }
        if(inName[len - 3] != '.'
            || inName[len - 2] != 'c'
            || inName[len - 1] != 'l'){

            throwError(0, -6, inName, (char)65);
            return 0;
        }

    }

    /* Set input source.*/
    yyin = fopen(inName, "r");

    /* Lex till break at end of file or error.*/
    while(1){
        /* ii - loop variable
         * newNode - Construct a node for each token
         * strVal - value of regex match
         * tokVal - indicates which token_t has been parsed
        */
        int ii;
        struct node * newNode;
        char* strVal;
        char* tokVal;

        /* Get the next token.*/
        tok = yylex();
        numTokens++;

        /* (int)tok values < -1 indicate errors.*/
        error = (int)tok;

        /* For ints, make sure values are < MAX_INT
         *  and trim leading 0's using a kludge of
         *  the worst kind.
        */
        strVal = strdup(yytext);
        if((int)tok == 16){
            long int literalInt = strtol(strVal, 0, 10);
            if(literalInt < 0 || literalInt > 2147483647){
                error = -4;
            }
            while(strVal[0] == '0'){
                strVal++;
            }
            if(strlen(strVal) == 0){
                strVal--;
                strVal[0] = '0';
            }
        }

        /* If we have a string, manualy trim quotes
         *  and check against max string length
        */
        if((int)tok == 35){
            int len = strlen(strVal);
            if (len > 1024){
                error = -5;
                break;
            }
            strVal[len - 1] = 0;
            strVal += 1;
        }

        /* error == -1 EOF scanned
         * error <  -1 scanner error.
         */ 
        if(error < 0){
            break;
        }

        /* Get string value of token tolower.
         * ascii offset.
        */
        tokVal = strdup(TOKEN_STRING[tok]);
        for(ii=0; tokVal[ii]; ii++){
            tokVal[ii] += 32;
        }

        /* Create and populate our new node & push to list.*/
        newNode = malloc(sizeof(*newNode));
        newNode -> head = tokVal;
        newNode -> lino = numLines + 1;
        newNode -> val = strVal;
        newNode -> next = tokens;
        tokens = newNode;
    }

    /* What should our filename be?*/
    strcpy(outName, argv[1]);
    strcat(outName, "-lex");

    /* Check for errors.*/
    if(error < -1){
        char* errMsg = strdup(yytext);
        throwError(numLines, error, errMsg, strlen(errMsg));
        return error;
    } else if (numTokens == 1){
        /* Single token implies empty file (possibly with comments)*/
        outFile = fopen(outName, "w");
        fclose(outFile);
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
        outFile = fopen(outName, "w");
        for(; tokens != NULL; tokens = tokens -> next){
            fprintf(outFile, "%d\n", tokens->lino);
            fprintf(outFile, "%s\n", tokens->head);
            /* Some data-types require us to output associated lexeme*/
            if(!(strcmp(tokens -> head, "identifier") &&
                strcmp(tokens -> head, "integer") &&
                strcmp(tokens -> head, "string") &&
                strcmp(tokens -> head, "type")) ){
                fprintf(outFile, "%s\n", tokens->val);
            }
        }

        /* You BETTER close that file.*/
        fclose(outFile);
    }
    return 0;
}
