This parser was constructed using cPython 2.7 and PLY version 3.8.
The following files are present.

bad.cl:
    A COOL file that should not parse. Case expression with empty body.

good.cl:
    A COOL file that should successfully parse. Wild and wacky testing.

lex.py, yacc.py: 
    Required dependencies.

main.py:
    This file is divided into three sections, setup, parser definition and output/serialization.
    (See below)

readme.txt:
    This file.

references.txt:
    List of references and topics.


main.py discussion:
    setup:
    As in Weimer's video, the lexer is setup using a dummy python class and the supplied
cl-lex file. From the provided file, we note the last token and last line to provide an error
message in the case that the parser reaches the end of input before completing a parse.

    parser definition:
    Tokens and precedence rules are taken from the CRM. Below is a list of parse rules that
may not be obvious derived from the CRM page titled "Cool Syntax."

program -> classlist
classlist -> class; | class; classlist
    Program is a non-empty list of classes

featurelist -> feature; featurelist | \epsilon
    A featurelist is either empty or is a feature followed by a feature list

feature -> attribute_no_init | attribute_init | method_no_args | method_args
    Using seperate rules to parse methods with formal arguments or without allows us to
      simplify the parsing of formals. When parsing a method without arguments, the empty
      list is placed in ast[3] where the formallist would be for a method_args. Both method
      types are output as 'method.'
    
formallist -> formal, formallist | formal
    Due to the above, it is allowed that formallists are non-empty

    Dynamic and static dispatch appear under the same rule in the CRM but are considered two
different types of node when parsing.
        

arglist -> expr B | \epsilon
B       -> ,expr B | \epsilon
    To denote the actual arguments for all types of dispatch, use is made of the non-terminals
      'arglist' and 'B.' Together, these two rules reject ", expr, expr" and "expr, expr,"
      while accepting "", "expr" and "expr, expr."

exprlist -> expr | expr, exprlist
    arglist and exprlist differ in that exprlist is strictly non-empty. exprlist is only used
      in parsing block type expressions.

let -> LET bindinglist IN expr
bindinglist -> binding | binding, bindinglist
binding -> binding_no_init | binding_init
binding_no_init -> identifier : type
binding_init -> identifier : type <- expr
    A let consists of the token LET followed by a nonempty list of bindings where a binding
      is either a binding that has been initialized or a binding that has not.

switch -> CASE expr OF caselist ESAC
caselist -> case | case; caselist
case -> identifier : type => expr
    In the internal grammar, a cool case statement is called a 'switch' and each rule within
      the cool case statement is called a 'case.'

    Output and serialization
    These processes are handled in a self-documenting fashion.
