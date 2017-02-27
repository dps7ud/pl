import sys
from lex import LexToken
import yacc as yacc


#######
#setup#
#######

# Open file and read all lines, deleting newline
token_file = open(sys.argv[1], 'r')
token_lines = token_file.readlines()
token_file.close()
token_lines = [a.replace('\n','').replace('\r','') for a in token_lines]

# List of token tuples
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
    result = token_lines[0]#.replace('\n','').replace('\r','')
    token_lines = token_lines[1:]
    return result


# Last token and last linono in case we read EOF mid-parse
# This feels dirty
last_line = 0
last_token = 'EOF'

#Copy everything from file to token list
while token_lines:
    line_number = read_token()
    token_type = read_token()
    token_lexeme = token_type
    # These have associated lexemes
    if token_type in {'type', 'integer', 'string', 'identifier'}:
        token_lexeme = read_token()
    else:
        token_type = token_type
    pa2_tokens.append( (line_number, token_type.upper(), token_lexeme) )
    last_line = line_number
    last_token = token_type

pa2lexer = Pa2Lexer()

###################
#Parser definition#
###################

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

precedence = (
        ('right', 'LARROW'),
        ('right', 'NOT'),
        ('nonassoc', 'LE', 'LT', 'EQUALS'),
        ('left', 'PLUS', 'MINUS'),
        ('left', 'TIMES', 'DIVIDE'),
        ('right', 'ISVOID'),
        ('right', 'TILDE'),
        ('left', 'AT'),
        ('left', 'DOT')
)

#program/class/feature/formal rules#

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
    p[0] = (p.lineno(1), 'no_inherits', p[2], p[4])

def p_class_inherit(p):
    'class : CLASS type INHERITS type LBRACE featurelist RBRACE'
    p[0] = (p.lineno(1), 'inherits', p[2], p[4], p[6])

def p_featurelist_none(p):
    'featurelist : '
    p[0] = []

def p_featurelist_some(p):
    'featurelist : feature SEMI featurelist'
    p[0] = [p[1]] + p[3]

def p_feature_attributenoinit(p):
    'feature : identifier COLON type'
    p[0] = ((p[1])[0], 'attribute_no_init', p[1], p[3])

def p_feature_attributeinit(p):
    'feature : identifier COLON type LARROW expr'
    p[0] = ((p[1])[0], 'attribute_init', p[1], p[3], p[5])

def p_feature_method_args(p):
    'feature : identifier LPAREN formallist RPAREN COLON type LBRACE expr RBRACE'
    p[0] = ((p[1])[0], 'method', p[1], p[3], p[6], p[8])

def p_feature_method_noargs(p):
    'feature : identifier LPAREN RPAREN COLON type LBRACE expr RBRACE'
    p[0] = ((p[1])[0], 'method', p[1], [], p[5], p[7])

def p_formallist_one(p):
    'formallist : formal'
    p[0] = [p[1]]

def p_formallist_some(p):
    'formallist : formal COMMA formallist'
    p[0] = [p[1]] + p[3]

def p_formal_only(p):
    'formal : identifier COLON type'
    p[0] = ((p[1])[0], p[1], p[3])

#type + id$
def p_type(p):
    'type : TYPE'
    p[0] = (p.lineno(1), p[1])

def p_identifier(p):
    'identifier : IDENTIFIER'
    p[0] = (p.lineno(1), p[1])

#Expressions#
def p_expr_assign(p):
    'expr : identifier LARROW expr'
    p[0] = ((p[1])[0], 'assign', p[1], p[3])

def p_expr_dynamic_dispatch(p):
    'expr : expr DOT identifier LPAREN arglist RPAREN'
    p[0] = ( (p[1])[0],'dynamic_dispatch', p[1], p[3], p[5])

def p_expr_static_dispatch(p):
    'expr : expr AT type DOT identifier LPAREN arglist RPAREN'
    p[0] = ( (p[1])[0], 'static_dispatch', p[1], p[3], p[5], p[7])

def p_expr_self_dispatch(p):
    'expr : identifier LPAREN arglist RPAREN'
    p[0] = ((p[1])[0], 'self_dispatch', p[1], p[3])

def p_exprlist_one(p):
    'exprlist : expr SEMI'
    p[0] = [p[1]]

def p_exprlist_many(p):
    'exprlist : expr SEMI exprlist'
    p[0] = [p[1]] + p[3]

def p_B_many(p):
    'B : COMMA expr B'
    p[0] = [p[2]] + p[3]

def p_B_none(p):
    'B : '
    p[0] = []

def p_arglist_one(p):
    'arglist : expr B'
    p[0] = [p[1]] + p[2]

def p_arglist_none(p):
    'arglist : '
    p[0] = []

def p_expr_if(p):
    'expr : IF expr THEN expr ELSE expr FI'
    p[0] = (p.lineno(1), 'if', p[2], p[4], p[6])

def p_expr_while(p):
    'expr : WHILE expr LOOP expr POOL'
    p[0] = (p.lineno(1), 'while', p[2], p[4])

def p_expr_block(p):
    'expr : LBRACE exprlist RBRACE'
    p[0] = (p.lineno(1), 'block', p[2])

def p_expr_new(p):
    'expr : NEW type'
    p[0] = (p.lineno(1), 'new', p[2])

def p_expr_isvoid(p):
    'expr : ISVOID expr'
    p[0] = (p.lineno(1), 'isvoid', p[2])

def p_expr_plus(p):
    'expr : expr PLUS expr'
    p[0] = ((p[1])[0], 'plus', p[1], p[3])

def p_expr_minus(p):
    'expr : expr MINUS expr'
    p[0] = ((p[1])[0], 'minus', p[1], p[3])

def p_expr_times(p):
    'expr : expr TIMES expr'
    p[0] = ((p[1])[0], 'times', p[1], p[3])

def p_expr_divide(p):
    'expr : expr DIVIDE expr'
    p[0] = ((p[1])[0], 'divide', p[1], p[3])

def p_expr_negate(p):
    'expr : TILDE expr'
    p[0] = (p.lineno(1), 'negate', p[2])

def p_expr_lt(p):
    'expr : expr LT expr'
    p[0] = ((p[1])[0], 'lt', p[1], p[3])

def p_expr_le(p):
    'expr : expr LE expr'
    p[0] = ((p[1])[0], 'le', p[1], p[3])

def p_expr_equals(p):
    'expr : expr EQUALS expr'
    p[0] = ((p[1])[0], 'eq', p[1], p[3])

def p_expr_not(p):
    'expr : NOT expr'
    p[0] = (p.lineno(1), 'not', p[2])

def p_expr_parens(p):
    'expr : LPAREN expr RPAREN'
    p[0] = p[2]
    
def p_expr_identifier(p):
    'expr : identifier'
    p[0] = ((p[1])[0], 'identifier', p[1])

def p_expr_integer(p):
    'expr : INTEGER'
    p[0] = (p.lineno(1), 'integer', p[1])
    
def p_expr_string(p):
    'expr : STRING'
    p[0] = (p.lineno(1), 'string', p[1])

def p_expr_true(p):
    'expr : TRUE'
    p[0] = (p.lineno(1), 'true')

def p_expr_false(p):
    'expr : FALSE'
    p[0] = (p.lineno(1), 'false')

def p_expr_let(p):
    'expr : LET bindinglist IN expr'
    p[0] = (p.lineno(1), 'let', p[2], p[4])

def p_bindinglist_one(p):
    'bindinglist : binding'
    p[0] = [p[1]]

def p_bindinglist_many(p):
    'bindinglist : binding COMMA bindinglist'
    p[0] = [p[1]] + p[3]

def p_binding_no_init(p):
    'binding : identifier COLON type'
    p[0] = ( (p[1])[0], 'let_binding_no_init', p[1], p[3])

def p_binding_init(p):
    'binding : identifier COLON type LARROW expr'
    p[0] = ( (p[1])[0], 'let_binding_init', p[1], p[3], p[5])

def p_expr_switch(p):
    'expr : CASE expr OF caselist ESAC'
    p[0] = (p.lineno(1), 'case', p[2], p[4])

def p_caselist_one(p):
    'caselist : case SEMI'
    p[0] = [p[1]]

def p_caselist_many(p):
    'caselist : case SEMI caselist'
    p[0] = [p[1]] + p[3]

def p_case_only(p):
    'case : identifier COLON type RARROW expr'
    p[0] = ( (p[1])[0], p[1], p[3], p[5])

def p_error(p):
    if p:
        print "ERROR: " + str(p.lineno) + ": Parser: syntax error near " + str(p.type)
        exit(1)
    else:
        print "ERROR: " + str(last_line) + ": Parser: syntax error near " + str(last_token)
        exit(1)

##########################
#Output and serialization#
##########################

def print_list(ast, print_element_func):
    # Print a list of whatever is passed
    out_file.write(str(len(ast)) + '\n')
    for elem in ast:
        print_element_func(elem)

def print_class(ast):
    if ast[1] == 'inherits':
        # p[0] = (p.lineno(1), 'class_inherit', p[2], p[4], p[6])
        print_identifier(ast[2])
        out_file.write("inherits\n")
        print_identifier(ast[3])
        print_list(ast[4], print_feature)
    elif ast[1] == 'no_inherits':
        # p[0] = (p.lineno(1), 'class_noinherit', p[2], p[4])
        print_identifier(ast[2])
        out_file.write("no_inherits\n")
        print_list(ast[3], print_feature)

def print_binding(ast):
    out_file.write(ast[1] + '\n')
    if ast[1] == 'let_binding_no_init':
        #                                              id, type
        # p[0] = ( (p[1])[0], 'let_binding_no_init', p[1], p[3])
        print_identifier(ast[2])
        print_identifier(ast[3])
    elif ast[1] == 'let_binding_init':
        #                                           id, type, expr
        # p[0] = ( (p[1])[0], 'let_binding_init', p[1], p[3], p[5])
        print_identifier(ast[2])
        print_identifier(ast[3])
        print_expr(ast[4])

two_exprs = {'plus', 'times', 'divide', 'minus', 'lt', 'le', 'eq', 'while'}
one_expr = {'not', 'negate', 'isvoid'}

def print_expr(ast):
    # For all exprs print name and lineno
    out_file.write(str(ast[0]) + '\n')
    out_file.write(ast[1] + '\n')
    if ast[1] == 'assign':
        #p[0] = (p.lineno(1), 'assign', p[1], p[3])
        print_identifier(ast[2])
        print_expr(ast[3])
    elif ast[1] == 'dynamic_dispatch':
        #                                        expr,   id, arglist
        # p[0] = ( (p[1])[0],'dynamic_dispatch', p[1], p[3], p[5])
        print_expr(ast[2])
        print_identifier(ast[3])
        print_list(ast[4], print_expr)
    elif ast[1] == 'static_dispatch':
        #                                        expr, type,   id, arglist
        # p[0] = ( (p[1])[0], 'static_dispatch', p[1], p[3], p[5], [7])
        print_expr(ast[2])
        print_identifier(ast[3])
        print_identifier(ast[4])
        print_list(ast[5], print_expr)
    elif ast[1] == 'self_dispatch':
        # 'expr :                               id, arglist
        # p[0] = ((p[1])[0], 'self_dispatch', p[1], p[3])
        print_identifier(ast[2])
        print_list(ast[3], print_expr)
    elif ast[1] == 'if':
        # p[0] = (p.lineno(1), 'if', p[2], p[4], [6])
        print_expr(ast[2])
        print_expr(ast[3])
        print_expr(ast[4])

    elif ast[1] == 'block':
        #     out_file.write(ast[1] + '\n')
        print_list(ast[2], print_expr)
    elif ast[1] == 'let':
        # expr                      bindinglist, expr
        # p[0] = (p.lineno(1), 'let', p[2], p[4])
        print_list(ast[2], print_binding)
        print_expr(ast[3])
    elif ast[1] == 'case':
        #                              expr, caselist
        # p[0] = (p.lineno(1), 'case', p[2], p[4])
        print_expr(ast[2])
        print_list(ast[3], print_case)
    elif ast[1] == 'new':
        #                           type
        #p[0] = (p.lineno(1), 'new', p[2])
        print_identifier(ast[2])
    elif ast[1] in one_expr:
        # p[0] = (p.lineno(1), 'isvoid', p[1])
        print_expr(ast[2])
    elif ast[1] in two_exprs:
        # p[0] = (p.lineno(1), 'minus', p[1], p[3])
        print_expr(ast[2])
        print_expr(ast[3])
    elif ast[1] == 'integer':
        # p[0] = (p.lineno(1), 'integer', p[1])
        out_file.write(str(ast[2]) + '\n')
    elif ast[1] == 'string':
        # p[0] = (p.lineno(1), 'string', p[1])
        out_file.write(ast[2] + '\n')
    elif ast[1] == 'identifier':
        # p[0] = (p.lineno(1), 'identifier', p[1])
        print_identifier(ast[2])
    elif ast[1] in {'true', 'false'}:
        # Since t/f are the names of these expressions,
        pass

def print_case(ast):
    #                       id, type, expr
    # p[0] = ( (p[1])[0], p[1], p[2], p[3])
    print_identifier(ast[1])
    print_identifier(ast[2])
    print_expr(ast[3])

def print_feature(ast):
    out_file.write(ast[1] + '\n')
    if ast[1] == 'attribute_no_init':
        # p[0] = (p.lineno(1), 'attribute_no_init', p[1], p[3])
        print_identifier(ast[2])
        print_identifier(ast[3])
    elif ast[1] == 'attribute_init':
        # p[0] = (p.lineno(1), 'attribute_init', p[1], p[3], p[5])
        print_identifier(ast[2])
        print_identifier(ast[3])
        print_expr(ast[4])
    elif ast[1] == 'method':
        # p[0] = ((p[1])[0], 'method', p[1], p[3], p[6], p[8])
        #                              id  , flst, type, expr
        print_identifier(ast[2])
        print_list(ast[3], print_formal)
        print_identifier(ast[4])
        print_expr(ast[5])

def print_formal(ast):
    #formal : id, type
    print_identifier(ast[1])
    print_identifier(ast[2])

def print_program(ast):
    #program : classlist
    print_list(ast,print_class)

def print_identifier(ast):
    #identifier : (line, id)
    out_file.write(str(ast[0]) + '\n')
    out_file.write(ast[1] + '\n')

# Build parser from defn, using dummy lexer
parser = yacc.yacc()
ast = yacc.parse(lexer=pa2lexer)
# Output
out_file = open(sys.argv[1][:-4] + "-ast", 'w')
print_program(ast)
out_file.close()
