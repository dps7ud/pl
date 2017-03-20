class Main{
  main() : Object { 
    out_string("Hello, world.\n") 
  } ;
};
    
class A inherits B{
    a : Int;
};
class B inherits C{
    a : Int;
};
class C inherits A{
    a : Int;
};
