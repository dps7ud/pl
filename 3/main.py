import sys
from lex import LexToken
import yacc as yacc

pa2_tokens = []

class Pa2Lexer(object):
    """Dummy lexer object to pass tokens from list of tokens"""
    def token(arg):
        global pa2_tokens
        if pa2_tokens:
            (line, token_type, lexeme) = pa2_tokens[0]
            pa2_tokens = pa2_tokens[1:]
            tok = LexToken()
            tok.type = token_type
            tok.value = lexeme
            tok.lineno = line
            tok.lexpos = 0
            return tok
        else:
            return None

def read_token():
    """Used to build token list from input file"""
    global token_lines
    result = token_lines[0].strip()
    token_lines = token_lines[1:]
    return result

token_file = open(sys.argv[1], 'r')
token_lines = token_file.readlines()
token_file.close()

while token_lines:
    """Copy everything from file to token list"""
    line_number = read_token()
    token_type = read_token()
    token_lexeme = token_type
    if token_type in {'type', 'integer', 'string', 'identifier'}:
        token_lexeme = read_token()
    else:
        token_type = token_type
    pa2_tokens.append( (line_number, token_type.upper(), token_lexeme) )

pa2lexer = Pa2Lexer()

tokens = (
    'AT',
    'CASE',
    'CLASS',
    'COLON',
    'COMMA',
    'DIVIDE',
    'DOT',
    'ELSE',
    'EQUALS',
    'ESAC',
    'FALSE',
    'FI',
    'IDENTIFIER',
    'IF',
    'IN',
    'INHERITS',
    'INTEGER',
    'ISVOID',
    'LARROW',
    'LBRACE',
    'LE',
    'LET',
    'LOOP',
    'LPAREN',
    'LT',
    'MINUS',
    'NEW',
    'NOT',
    'OF',
    'PLUS',
    'POOL',
    'RARROW',
    'RBRACE',
    'RPAREN',
    'SEMI',
    'STRING',
    'THEN',
    'TILDE',
    'TIMES',
    'TRUE',
    'TYPE',
    'WHILE'
    )

def p_program_classlist(p):
    'program : classlist'
    p[0] = p[1]

def p_classlist_single(p):
    'classlist : class SEMI'
    p[0] = [p[1]]

def p_classlist_many(p):
    'classlist : class SEMI classlist'
    p[0] = [ p[1] ] + p[3]

def p_class_noinherit(p):
    'class : CLASS type LBRACE featurelist RBRACE'
    p[0] = (p.lineno(1), 'class_noinherit', p[2], p[4])

def p_class_inherit(p):
    'class : CLASS type INHERITS type LBRACE featurelist RBRACE'
    p[0] = (p.lineno(1), 'class_inherit', p[2], p[4], p[6])

def p_type(p):
    'type : TYPE'
    p[0] = (p.lineno(1), p[1])

def p_identifier(p):
    'identifier : IDENTIFIER'
    p[0] = (p.lineno(1), p[1])

def p_featurelist_none(p):
    'featurelist : '
    p[0] = []

def p_featurelist_some(p):
    'featurelist : feature SEMI featurelist'
    p[0] = [p[1]] + p[3]

def p_feature_attributenoinit(p):
    'feature : identifier COLON type'
    p[0] = (p.lineno(1), 'attribute_no_init', p[1], p[3])

def p_feature_attributeinit(p):
    'feature : identifier COLON type LARROW exp'
    p[0] = (p.lineno(1), 'attribute_init', p[1], p[3], p[5])

def p_exp_integer(p):
    'exp : INTEGER'
    p[0] = (p.lineno(1), 'integer', p[1])
    
def p_exp_plus(p):
    'exp : exp PLUS exp'
    p[0] = (p.lineno(1), 'plus', p[1], p[3])

def p_exp_minus(p):
    'exp : exp MINUS exp'
    p[0] = (p.lineno(1), 'minus', p[1], p[3])

def p_exp_times(p):
    'exp : exp TIMES exp'
    p[0] = (p.lineno(1), 'times', p[1], p[3])

def p_exp_divide(p):
    'exp : exp DIVIDE exp'
    p[0] = (p.lineno(1), 'divide', p[1], p[3])

def p_error(p):
    if p:
        print "ERROR+: ", p.lineno, ": Parser: parse error near", p.type
        exit(1)
    else:
        print "Syntax error at EOF" #EOF lineno

###Output###
############

def print_list(ast, print_element_func):
    out_file.write(str(len(ast)) + '\n')
    for elem in ast:
        print_element_func(elem)

def print_class(ast):
    '''class : CLASS type LBRACE featurelist RBRACE
           | CLASS type INHERITS type LBRACE featurelist RBRACE'''
    if len(ast) == 5:
        print_identifier(ast[2])
        out_file.write("inherits\n")
        print_identifier(ast[3])
        print_list(ast[4], print_feature)
    else:
        print_identifier(ast[2])
        out_file.write("no_inherits\n")
        print_list(ast[3], print_feature)

def print_exp(ast):
    

def print_feature(ast):
    #TODO: support methods
    '''feature : identifier COLON type LARROW exp
               | identifier COLON type'''
    if len(ast) == 5:
        out_file.write("attribute_init\n")
        print_identifier(ast[2])
        print_identifier(ast[3])
        print_exp(ast[5])
    else:
        out_file.write("attribute_no_init\n")
        print_identifier(ast[2])
        print_identifier(ast[3])

def print_program(ast):
    print_list(ast,print_class)

def print_identifier(ast):
    out_file.write(str(ast[0]) + '\n')
    out_file.write(ast[1] + '\n')


# Build parser from rules
parser = yacc.yacc()
ast = yacc.parse(lexer=pa2lexer)

out_file = open(sys.argv[1][:-4] + "-ast", 'w')
print_program(ast)
out_file.close()











