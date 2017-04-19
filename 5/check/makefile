interp: typedefs.cmx deserialize.cmx main.cmx
	ocamlopt -o interp typedefs.cmx deserialize.cmx main.cmx
typedefs.cmx: typedefs.ml
	ocamlopt -c typedefs.ml
deserialize.cmx: deserialize.ml
	ocamlopt -c deserialize.ml
main.cmx: main.ml
	ocamlopt -c main.ml
