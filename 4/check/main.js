var fs = require('fs');
var ts = require("./toposort.js");
var rf = require("./read_funcs.js");
var st = require("./symboltable.js");
var ec = require("./expr_checks.js");


// Puts error message to stdout and ends program
function put_error(line, message){
    var str = "ERROR: " + line + ": Type-Check: " + message;
    console.log(str);
    process.exit(1);
};

// Construct and return an array of built-in classes
// Probably should have just written the whole thing in JSON
function setup(){
    var classes = [];
    var class_names = ["Bool", "IO", "Int", "Object", "String"];
    for (var ii = 0; ii < class_names.length; ii++){
        var cool_class = {};
        cool_class.name = {
            line: "0", 
            id: class_names[ii], 
            toString : function() {return this.line + '\n' + this.id + '\n'}
        }
        cool_class.inherits = false;
        cool_class.features = [];

        cool_class.toString = function(){
            var str = this.name.toString() + this.features.length + '\n';
            for (var ii = 0; ii < this.features.length; ii++){
                str += this.features[ii].toString();
            }
            return str;
        };
        switch(cool_class.name.id){
            case "IO":
                out_string = {};
                out_string.name = { line : "0", id: "out_string"
                    , toString: function(){return this.id.toString();} }
                formal = {name:{line:'0',id:"x"}, f_type: {line:'0',id:"String"}};
                out_string.formals = [formal];
                out_string.ret_type = {line: "-1",id:"SELF_TYPE"};
                out_string.kind = "method";
                out_string.toString = function() {
                    return this.body
                }

                out_int = {};
                out_int.name = { line: "0", id: "out_int", toString: function(){return this.id}}
                formal = {name: {line:'0',id:"x"}, f_type: {line:'0',id:"Int"}};
                out_int.formals = [formal];
                out_int.ret_type = {line: "0",id:"SELF_TYPE"};
                out_int.kind = "method";
                out_int.toString = function() {
                    return this.body
                }

                in_string = {};
                in_string.name = { line : "0", id: "in_string"
                    , toString: function(){return this.id.toString();} }
                in_string.formals = [];
                in_string.ret_type = {id:"String"};
                in_string.kind = "method";
                in_string.toString = function() {
                    return this.body
                }

                in_int = {};
                in_int.name = { line : "0", id: "in_int"
                    , toString: function(){return this.id.toString();} }
                in_int.formals = [];
                in_int.ret_type = {line: "0",id:"Int"};
                in_int.kind = "method";
                in_int.toString = function() {
                    return this.body
                }

                cool_class.features = [in_int, in_string, out_int, out_string];
                break;
            case "Object":
                abort = {};
                abort.name = { line: '0', id: "abort", toString: function(){return this.id}}
                abort.formals = [];
                abort.ret_type = {line: "0",id:"Object"};
                abort.kind = "method";
                abort.toString = function() {
                    return this.body
                }

                type_name = {};
                type_name.name = {
                    line: '0', 
                    id: "type_name", 
                }
                type_name.formals = [];
                type_name.ret_type = {line: "0",id:"String"};
                type_name.kind = "method";
                type_name.toString = function() {
                    return this.body
                }

                copy = {};
                copy.name = "copy"; 
                copy.name = {line: '0', id: "copy", toString: function(){return this.id}}
                copy.formals = [];
                copy.ret_type = {line: "0",id:"SELF_TYPE"};
                copy.kind = "method";
                copy.toString = function() {
                    return this.body
                }
                cool_class.features = [abort, copy, type_name];
                break;
            case "String":
                length = {}
                length.name = "length";
                length.name = {line: '0', id: "length", toString: function(){return this.id}}
                length.formals = [];
                length.ret_type = {line: "0",id:"Int"};
                length.kind = "method";
                length.toString = function() {
                    return this.body
                }

                concat = {}
                concat.name = {line: '0', id: "concat", toString: function(){return this.id}}
                formal = {name: {line:'0',id:"s"}, f_type: {line:'0',id:"String"}};
                concat.formals = [formal];
                concat.ret_type = {line: "0",id:"String"};
                concat.kind = "method";
                concat.toString = function() {
                    return this.body
                }

                substr = {}
                substr.name = "substr";
                substr.name = {line: '0', id: "substr", toString: function(){return this.id}}
                formal = {name: {line:'0',id:"i"}, f_type: {line:'0',id:"Int"}};
                formal_2 = {name: {line:'0',id:"l"}, f_type: {line:'0',id:"Int"}};
                substr.formals = [formal, formal_2];
                substr.ret_type = {line: "0",id:"String"};
                substr.kind = "method";
                substr.toString = function() {
                    return this.body
                }
                cool_class.features = [concat, length, substr];
                break;
            default:
                break;
        }
        classes.push(cool_class);
    }
    for (var ii = 0; ii < classes.length; ii++){
        for (var jj = 0; jj < classes[ii].features.length; jj++){
            classes[ii].features[jj].body = classes[ii].features[jj].name.line 
                + '\n' + classes[ii].features[jj].ret_type.id + '\ninternal\n' 
                + classes[ii].name.id + '.' + classes[ii].features[jj].name.id + '\n';
           // {
           //     name: classes[ii].name,
           //     ret_type: classes[ii].ret_type,
           // };
           // classes[ii].features[jj].body.toString = function() {
           //   return this.name.line + '\n' + this.ret_type.id + '\ninternal\n' 
           //       + classes[ii].name.id + '.' + this.name.id + '\n';
           //   
           // }
        }
    }
    return classes;
}

/* Checks for the following:
   - Multiple class definitions
   - Classes named SELF_TYPE
   - Inherits unknown
   - Inherits protected
   - Inheritance cycle
   - Main defined
*/
function check_hierarchy(classes){
    var parent_list = [];
    var s = new Set();
    /* Constructs the list detailing parent-child pairs for later use
       - checks for redefined classes
       - checks for SELF_TYPE definition
    */
    for (var ii = 0; ii < classes.length; ii++){
        var class_name = classes[ii].name.id.toString();
        if ( s.has(class_name) ){
            var line_num = Math.max(...classes.filter( (item) => {
                return item.name.id.toString() === class_name;
            }).map( (item) => {
                return parseInt(item.name.line);
            }))
            console.log("ERROR: " + line_num + ": Type-Check: Class "

                    + classes[ii].name.id.toString() + " redefined.");
            process.exit(1);
        }
        s.add(classes[ii].name.id.toString());
        if (classes[ii].name.id.toString() === "Object") continue;
        if (classes[ii].name.id.toString() === "SELF_TYPE") {
            console.log("ERROR: " + classes[ii].name.line 
                    + ": Type-Check: Class named SELF_TYPE.")
            process.exit(1);
        }
        if (classes[ii].inherits){
            parent_list.push(classes[ii].inherits);
        } else {
            parent_list.push(object_class);
        }
        parent_list.push(classes[ii]);
    }
    // Need a Main class
    if (! s.has("Main")){
        put_error("0", "class Main not found");
    }
    //TODO: Unify checks for Main and SELF_TYPE

    var pairs = ts.to_pairs(parent_list);
    var subs = ts.get_ith(pairs, 1);
    var supers = ts.get_ith(pairs, 0);
    

    var cant_inherit = new Set(["Bool", "Int", "String"]);
    for (var ii = 0; ii < supers.length; ii++){
        // Checks for undefined superclass
        if (supers[ii].name === undefined){
            var find = classes.filter(function(item){
                return item.name.id.toString() === supers[ii].id.toString();
            });
            if (find.length > 0) {
                supers[ii] = find[0];
            } else {
                console.log("ERROR: " + subs[ii].inherits.line + ": Type-Check: Class " 
                        + subs[ii].name.id.toString()
                        + " inherits from unknown class " + supers[ii].id.toString() );
                process.exit(1);
            }
        }
        // Checks for inherit from protected class
        if (cant_inherit.has(supers[ii].name.id.toString())){
            console.log("ERROR: " + subs[ii].inherits.line + ": Type-Check: Class "
                    + subs[ii].name.id.toString() + " inherits from " 
                    + supers[ii].name.id.toString());
            process.exit(1);
        }
    }
    var names = parent_list.map(function(item){
        // God, I hate javascript
        if (item.name !== undefined)
            return item.name.id.toString();
        else
            return item.id;
    });
    if( !ts.toposort(Array.from(new Set(names)), ts.to_pairs(names), [])){
        //TODO? better error, get cycle from ts.topo
        console.log("ERROR: 0: Type-Check: Inheritance cycle: ");
        process.exit(1);
    }
};

/* Checks for the following:
   - Method with unknown return type
   - Method with duplicate formal parameter
   - Method with formal parameter named self
   - Method with formal parameter of unknown type
   - Duplicate method definition
   - Duplicate attribute definition
   - Attribute named self
   - Attribute of unknown type
   - Main.main defined
   - Main.main with zero parameters
   - Super redefines attribute

   And constructs class_map string
*/
function method_checks(classes){
    var parent_list = [];
    for (var ii = 0; ii < classes.length; ii++){
        if (classes[ii].name.id.toString() === "Object") continue;
        if (classes[ii].inherits){
            var find = classes.filter(function(item){
                return item.name.id.toString() === classes[ii].inherits.id;
            });
            parent_list.push(find[0]);
        } else {
            parent_list.push(object_class);
        }
        parent_list.push(classes[ii]);

        // Check if defines a method twice
        // Count occurences of method names in class body
        var counts = {};
        var methods = classes[ii].features.filter( (item) => {
            return item.kind === "method";
        });
        // While we build our counts, check things for which we don't need inheratence info
        for (var jj = 0; jj < methods.length; jj++){
            counts[methods[jj].name.id] = 
                (counts[methods[jj].name.id] || 0) + 1;
            // Check return type exits
            if (methods[jj].ret_type.id !== "SELF_TYPE"
                    && classes.filter( (item) => {
                        return item.name.id === methods[jj].ret_type.id;
                    }).length <= 0){
                var msg = "class " + classes[ii].name.id + " has method "
                    + methods[jj].name.id + " with unknown return type "
                    + methods[jj].ret_type.id;
                var line_number = methods[jj].ret_type.line;
                put_error(line_number, msg);
            }
            /* Check for 
               - duplicate parameters
               - unknown formal type
               - parameter names *self*
            */
            var formal_names = new Set();
            for (var kk = 0; kk < methods[jj].formals.length; kk++){
                if (formal_names.has(methods[jj].formals[kk].name.id)){
                    var msg = "class " + classes[ii].name.id + " has method "
                        + methods[jj].name.id + " with duplicate formal parameter named "
                        + methods[jj].formals[kk].name.id;
                    var line_num = methods[jj].formals[kk].name.line;
                    put_error(line_num, msg);
                }
                formal_names.add(methods[jj].formals[kk].name.id)
                if (methods[jj].formals[kk].name.id === "self"){
                    var msg = "class " + classes[ii].name.id + " has method "
                        + methods[jj].name.id + " with formal parameter named self";
                    put_error(methods[jj].formals[kk].name.line, msg);
                }
                if (classes.filter( (item) => {
                    return item.name.id === methods[jj].formals[kk].f_type.id;
                }).length <= 0){
                    var line_num = methods[jj].formals[kk].f_type.line;
                    var msg = "class " + classes[ii].name.id + " has method "
                        + methods[jj].name.id + " with formal parameter of unknown type "
                        + methods[jj].formals[kk].f_type.id;
                    put_error(line_num, msg);
                }
            }
        }
        // get the line number of the second definition
        // Correct implementation is to get second definition by heirarchy
        for (var name in counts){
            if (counts[name] > 1){
                var line_num = methods.filter( (item) => {
                    return item.name.id === name;
                }).map( (item) => {
                    return item.name.line;
                })[1];
                var msg = "class " + classes[ii].name.id + " redefines method " + name;
                put_error(line_num, msg);
            }
        }

        var attributes = classes[ii].features.filter( (item) => {
            return item.kind !== "method";
        });
        // Check for attribute errors
        for (var jj = 0; jj < attributes.length; jj++){
            // Check name != self
            if (attributes[jj].name.id === "self"){
                var msg = "class " + classes[ii].name.id + " has an attribute named self"
                var line_num = attributes[jj].name.line;
                put_error(line_num, msg);
            }
            // Check type exists
            if (attributes[jj].f_type.id !== "SELF_TYPE"
                    && classes.filter( (item) => {
                return item.name.id === attributes[jj].f_type.id;
            }).length <= 0) {
                var msg = "class " + classes[ii].name.id + " has attribute "
                    + attributes[jj].name.id + " with unknown type " + attributes[jj].f_type.id;
                var line_num = attributes[jj].f_type.line;
                put_error(line_num, msg);
            }
        }
    }

    var pairs = ts.to_pairs(parent_list);
    var subs = ts.get_ith(pairs, 1);
    var supers = ts.get_ith(pairs, 0);
    var ans = {};
    var destructable = parent_list.slice()
    ans.parent_map = ec.pmap(destructable);
    ans.imp_map = ec.imap(parent_list);

    // Construcs an inheritance chain from classes[ii] to Object
    function get_ancestry(class_obj){
        var ancestry = [class_obj];
        while (true){
            var index = -1;
            for(var ii = 0; ii < subs.length; ii++){
                if (subs[ii].name.id.toString() === class_obj.name.id.toString()){
                    index = ii;
                    break;
                }
            }
            if (index < 0){
                break;
            } 
            class_obj = supers[index];
            ancestry.push(class_obj);
        }
        return ancestry;
    }

    // Holds attributes for classes[ii] at index ii
    var class_attribs = [];
    for (var ii = 0; ii < classes.length; ii ++){
        var parents = get_ancestry(classes[ii]);
        var methods_at_index = [];
        var attribs_at_index = [];

        // Build methods and attributes for each class (includeing superclass features)
        for (var jj = 0; jj < parents.length; jj ++){
            methods_at_index = methods_at_index.concat( parents[jj].features.filter( (item)=>{
                return item.kind === "method";
            }).map( (item) => {
                item.def = parents[jj].name.id;
                return item;
            }));
            var to_add = parents[jj].features.filter(
                        (item)=>{return item.kind !== "method";}).map( (item) => {
                item.def = parents[jj].name.id;
                console.log(item)
                return item;
            });
            for (var kk = to_add.length-1; kk >= 0; kk--){
                attribs_at_index.unshift(to_add[kk]);
            }
        }

        // Special checks for Main.main
        if (classes[ii].name.id === "Main"){
            var main = methods_at_index.filter( (item) => {
                return item.name.id === "main";
            });
            if (main.length < 1){
                console.log("ERROR: 0: Type-Check: class Main method main not found");
                process.exit(1);
            }
            // Pick most recently defined, check later that all are the same
            main = main[0];
            if (main.formals.length > 0){
                console.log("ERROR: 0: Type-Check: class Main method " 
                        + "main with 0 parameters not found");
                process.exit(1);
            }
        }

        /*Need to have attribs acquired from superclasses
           in order to output to class_map in proper order
        */
        var only_super_attribs = attribs_at_index.filter( (item) => {
            return item.def !== classes[ii].name.id;
        });
        class_attribs.push(only_super_attribs);

        // Check for method redefinitions using *check_method_redefs*
        var attrib_counts = {};
        var method_counts = {};
        for (var kk = 0; kk < attribs_at_index.length; kk++){
            attrib_counts[attribs_at_index[kk].name.id] = 
                (attrib_counts[attribs_at_index[kk].name.id] || 0) + 1;
        }
        for (var kk = 0; kk < methods_at_index.length; kk++){
            method_counts[methods_at_index[kk].name.id] = 
                (method_counts[methods_at_index[kk].name.id] || 0) + 1;
        }
        for (var name in method_counts){
            if (method_counts[name] > 1) {
                var to_check = methods_at_index.filter( (item) => {
                    return item.name.id === name;
                });
                check_method_redefs(to_check);
            }
        }

        // Checks for redefined attribute
        for (var name in attrib_counts){
            if (attrib_counts[name] > 1) {
                var redef_attrib = attribs_at_index.filter( (item) => {
                    return item.name.id === name;
                });
                var bad_attrib = redef_attrib[redef_attrib.length - 2];
                var msg = "class " + bad_attrib.def + " redefines attribute "
                    + bad_attrib.name.id;
                put_error(bad_attrib.name.line, msg);
            }
        }
    }

    // Build class_map string
    var ret = "class_map\n" + classes.length + '\n';
    for (var ii = 0; ii < classes.length; ii++){
        var all_attribs = class_attribs[ii].concat( classes[ii].features.filter( (item) => {
            return item.kind !== "method";
        }));
        ret += classes[ii].name.id.toString() + '\n';
        ret += out_list(all_attribs);
    }
    ans.class_map = ret
    return ans;
}

// Build string from list (used for attributes)
function out_list(list){
    var str = list.length + '\n';
    for (var ii = 0; ii < list.length; ii++){
        if (list[ii].kind === "attribute_init"){
            str += "initializer\n"
        str += list[ii].name.id + '\n';
        str += list[ii].f_type.id + '\n';
        str += list[ii].init.toString();
        console.log("init type", list[ii].init.type)
        } else {
            str += "no_initializer\n"
        str += list[ii].name.id + '\n';
        str += list[ii].f_type.id + '\n';
        }
    }
    return str;
}

/* Checks for the following:
   - Redefines method and changes number of formals
   - Redefines method and changes return type
   - Redefines method and changes type of formal
*/
function check_method_redefs(method_list){
    // This function checks for redefinition errors
    var earliest = method_list[method_list.length - 1];
    for (var ii = method_list.length - 1; ii >= 0; ii--){
        // Check number of formals
        if (method_list[ii].formals.length !== earliest.formals.length){
            var msg = "class " + method_list[ii].def + " redefines method "
                + method_list[ii].name.id + " and changes number of formals";
            put_error(method_list[ii].name.line, msg);
        }
        // Check return type
        if (method_list[ii].ret_type.id !== earliest.ret_type.id){
            var msg = "class " + method_list[ii].def + " redefines method "
                + method_list[ii].name.id + " and changes return type (from " 
                + earliest.ret_type.id + " to " + method_list[ii].ret_type.id + ")";
            put_error(method_list[ii].ret_type.line, msg);
        }
        // Check formal types (already know we have the same number)
        for (var jj = 0; jj < earliest.formals.length; jj++){
            if (earliest.formals[jj].f_type.id !== method_list[ii].formals[jj].f_type.id){
                var line_num = method_list[ii].formals[jj].f_type.line;
                var msg = "class " + method_list[ii].def + " redefines method "
                    + method_list[ii].name.id + " and changes type of formal " 
                    + method_list[ii].formals[jj].name.id;
                put_error(line_num, msg);
            }
        }
    }
}

function run(){
    // Read input
    if (process.argv.length !== 3){
        console.log("Need a file");
        process.exit(1);
    }
    var in_file = process.argv[2];
    fs.readFile(in_file, "utf-8", (err, data) => {
        if (err){
            console.log("Error opening file\n");
            process.exit(1);
        }
        var lines = data.split("\n");
        // Deserialize AST
        var ast = rf.read_program(lines);
        //If there's such a thing as idiomatic javascript, this isn't it
        base = setup();
        object_class = base[3];
        for (var ii = 0; ii < base.length; ii++){
//                console.log(base[ii].toString());
        }


        ast.classes = ast.classes.concat(base);
        // Classes are output in alphabetical order
        ast.classes.sort(function(a, b){
            if(a.name.id.toString() < b.name.id.toString()) return -1;
            if(a.name.id.toString() > b.name.id.toString()) return 1;
            return 0;
        });
        check_hierarchy(ast.classes);
        var maps_out = method_checks(ast.classes);
        var everything = maps_out.class_map + maps_out.imp_map + maps_out.parent_map
            + ast.toString();

//        console.log(ast);
//        console.log(ast.toString());

        fs.writeFile(in_file.substr(0, in_file.lastIndexOf('.')) + '.cl-type'
                , everything);
//                , maps_out.imp_map);
//                , maps_out.parent_map);
//                , maps_out.class_map);
    });
}
var base;
var object_class;
run()
