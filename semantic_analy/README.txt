David Stolz - dps7ud
Files:
    main.js         -> handles file IO and non-expression type checking
    expr_checks.js  -> handles expression type-checking
    read_funcs.js   -> deserializes input file and builds AST
    symboltable.js  -> provided symboltable with minimal adjustments
    toposort.js     -> topological sort function + a few other useful functions
    good.cl,bad1.cl,
    bad2.cl, bad3.cl-> Good and bad testcases

    Testcases included were ones I had a harder time predicting.

Cups of coffee consumed: 14
Missed nights of sleep: 1
Times we've thought
  "there must be a way
  to do this in js"
  but then there wasn't: 6

    The type-checking of expressions was not the most difficult part of this assignment.
The general level of kaos and mayhem in the submitted code is possibly due to the
author's unfamiliarity with the language but anecdotal evidence would indicate
that javascript encourages a well-rounded disorder. 
    While some short-sighted design decisions were made, the downright unexpressiveness
of the language drove the production the loose grouping of scotch-taped kludges we'll
call a semantic analyzer.
    In the end, writing individual typing rules could be categorized as "tricky"
but in a fun sort of way. You know, like putting together a puzzle. Navigating
javascript is more like watching some guy put together a puzzle where all the
pieces are one color except the person you're watching is also you. Oh, and the
manufacturer decided not to have any edges so you/him have to come up with 
something for that even though PLENTY OF OTHER PUZZLES have edges. Like, it's
not a bizarre and wacky insight to look at two numbers and notice which one is
bigger instead of which one would come first in a dictionary of numbers. Because 
there is no such thing as a dictionary of numbers. Do you know why? Because that's 
a ridiculous way to think about numbers.

    Things to do better next time:
    
    1. Organization of files. Currently the responsibilities and promises
        of each file are murky at best.
    2. Data structures: if we need to draw a picture that is necessarily 
    non-planar to remember how things are arranged, we might want to rethink 
    our major life decisions.
    3. Use a different language: seriously
    4. Planning. we found ourselves in a situation where it was necessary to
        club together information in an ad hoc fashion.
