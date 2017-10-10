Files:
references.txt
  A list of resources consulted.

readme.txt
  This file.

study.txt
  File containing human study completion code.

test1.cl: nasty string concat, formatting.
test2.cl: messy inheritance and method dispatch.
test3.cl: a case statement with side effects
test4.cl: maximum stack depth

a_typedefs.ml
  Contains type definitions used in the interpreter. Since the grading server compiles
  files in alphabetical order, we have adapted in our naming convention.

deserialize.ml
  Contains functions to deserialize the _.cl-type file and construct the parent map,
  implementation map and class map.

main.ml
  Everything else. Broken into four sections. They are:
    1. debugging/tracing
      - Since the overhead associated with these functions slows the interpreter
      noticeably, the code must be commented unless actively engaged in debugging.

    2. Helper functions. Including:
        - String formatting: correctly replacing \n and \t since ocaml 3.09 doesn't
        have ANYTHING built in.
        - Error printing functions
        - Functions used to parse integers from stdin
        - Functions used to calculate correct case branch
        - Functions to keep track of store addresses and stack frames

    3. eval, of which, we will offer highlights:
        - Let: we evaluate a let with multiple bindings by recursively calling
        eval to execute each binding. If we have a let with no bindings, we simply
        evaluate the let body with the current store. A let without bindings cannot
        pass type checking so we need not worry about evaluating a let without previously
        evaluating it's bindings.
        - Internally, self dispatch is represented by Dispatch(None, _, _)
        - New SELF_TYPE and self dispatch are simply routed to  and new type(so) 
        and dispatch on so respectively.
        - All arithmetic falls back on ocaml's Int32 arithmetic.
        - Equality falls back on ocaml's *==* operator.
        - Built in functions are implemented as a separate expression kind 
        *internal* and calls to these functions simply have a body expression
        of kind *internal*. These are handled individually by matching function name.

    4. Entry point: we execute by hand (new Main).main() in order to enter into execution.

