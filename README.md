# Programming Languages

A repository for CS 4610 Programming Languages,
University of Virginia, Spring 2017.

### COOL
The majority of this repository consists of an implementation of the
Classroom Object Oriented Language (COOL), an imperative, strongly-typed, single-inheritance
pedagogical language. COOL is specified in the [COOL Reference Manual](http://www.cs.virginia.edu/~cs415/cool-manual/cool-manual.html) (CRM).

### Implementation
This implementation is constructed of four modules as detailed below.

##### Lexical Analyser
Implemented using C (gcc 4.1) and flex (fast lexical analyser generator).
Specified in the CRM under [Lexical Rules](http://www.cs.virginia.edu/~cs415/cool-manual/node33.html).
The lexical analyser consumes COOL source code and emits either an error or
a serialized list of COOL tokens.

##### Parser
Implemented using cPython 2.7 and PLY (Python Lex Yacc).
Specified in the CRM under [COOL Syntax](http://www.cs.virginia.edu/~cs415/cool-manual/node39.html).
The parser consumes a serialized list of COOL tokens and emits either an error or
a serialized abstract syntax tree.

##### Semantic Analyser
Implemented using Node.js v6.10.
Specified in the CRM under [Type Rules](http://www.cs.virginia.edu/~cs415/cool-manual/node41.html).
The semantic analyser will consume a serialized abstract syntax tree and emit either
an error or serialized versions of a class map, implementation map, parent map and 
abstract syntax tree.

##### Interpreter
Implemented using OCaml v3.09.
Specified in the CRM under [Operational Semantics](http://www.cs.virginia.edu/~cs415/cool-manual/node44.html).
The interpreter consumes a class map, implementation map, parent map and abstract
syntax tree and will execute the COOL program described by that input.
