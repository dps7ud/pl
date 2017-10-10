interp: a_typedefs.cmx deserialize.cmx main.cmx
	ocamlopt -o interp a_typedefs.cmx deserialize.cmx main.cmx
a_typedefs.cmx: a_typedefs.ml
	ocamlopt -c a_typedefs.ml
deserialize.cmx: deserialize.ml
	ocamlopt -c deserialize.ml
main.cmx: main.ml
	ocamlopt -c main.ml
