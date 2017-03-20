var fs = require('fs');
var ts = require("./toposort.js");
var rf = require("./read_funcs.js");

function put_error(line, message){
    var str = "ERROR: " + line + ": Type-Check: " + message;
    console.log(str);
    process.exit(1);
};

/* Process input*/
function setup(){
    var classes = [];
    var class_names = ["Bool", "IO", "Int", "Object", "String"];
    for (var ii = 0; ii < class_names.length; ii++){
        var cool_class = {};
        cool_class.name = {line: -1, id: class_names[ii]};
        cool_class.inherits = false;
        cool_class.features = [];

        cool_class.toString = function(){
            var str = this.name.toString();
            for (var ii = 0; ii < this.features.length; ii++){
                str += '\n';
                str += this.features[ii].toString();
            }
            return str;
        };
        switch(cool_class.name){
            case "IO":
                out_string = {};
                out_string.name = { line : -1, id: "out_string"
                    , toString: function(){return this.id.toString();} }
                formal = {name:"x", f_type: "String"};
                out_string.formals = [formal];
                out_string.ret_type = "SELF_TYPE";
                out_string.kind = "method";

                out_int = {};
                out_int.name = { line: -1, id: "out_int", toString: function(){return this.id}}
                formal = {name: "x", f_type: "Int"};
                out_int.formals = [formal];
                out_int.ret_type = "SELF_TYPE";
                out_int.kind = "method";

                in_string = {};
                in_string.name = { line : -1, id: "in_string"
                    , toString: function(){return this.id.toString();} }
                in_string.formals = [];
                in_string.ret_type = "String";
                in_string.kind = "method";

                in_int = {};
                in_int.name = { line : -1, id: "in_int"
                    , toString: function(){return this.id.toString();} }
                in_int.formals = [];
                in_int.ret_type = "Int";
                in_int.kind = "method";

                cool_class.features = [out_string, out_int, in_string, in_int];
                break;
            case "Object":
                abort = {};
                abort.name = { line: -1, id: "abort", toString: function(){return this.id}}
                abort.formals = [];
                abort.ret_type = "Object";
                abort.kind = "method";

                type_name = {};
                type_name.name = {line: -1, id: "type_name", toString: function(){return this.id}}
                type_name.formals = [];
                type_name.ret_type = "String";
                type_name.kind = "method";

                copy = {};
                copy.name = "copy"; 
                copy.name = {line: -1, id: "copy", toString: function(){return this.id}}
                copy.formals = [];
                copy.ret_type = "SELF_TYPE";
                copy.kind = "method";
                cool_class.features = [abort, type_name, copy];
                break;
            case "String":
                length = {}
                length.name = "length";
                length.name = {line: -1, id: "length", toString: function(){return this.id}}
                length.formals = [];
                length.ret_type = "Int";
                length.kind = "method";

                concat = {}
                concat.name = {line: -1, id: "concat", toString: function(){return this.id}}
                formal = {name: "s", f_type: "String"};
                concat.formals = [formal];
                concat.ret_type = "String";
                concat.kind = "method";

                substr = {}
                substr.name = "substr";
                substr.name = {line: -1, id: "substr", toString: function(){return this.id}}
                formal = {name: "i", f_type: "Int"};
                formal_2 = {name: "l", f_type: "Int"};
                substr.formals = [formal, formal_2];
                substr.ret_type = "String";
                substr.kind = "method";
                cool_class.features = [length, concat, substr];
                break;
            default:
                break;
        }
        classes.push(cool_class);
    }
    return classes;
}

function out_feature_list(class_obj, wanted_kind){
    var str = "\n";
    var to_add = class_obj.features.filter(function(feature){
        return feature.kind.startsWith(wanted_kind);
    });
    str += to_add.length + '\n';
    for (var ii = 0; ii < to_add.length; ii++){
        str += to_add[ii].toString();
        str += '\n';
    }
    return str;
}

function out_class_map(classes){
    var ret = "class_map\n";
    ret += classes.length;
    ret += "\n";
    for (var ii = 0; ii < classes.length; ii++){
        ret += classes[ii].name.id.toString();
        ret += out_feature_list(classes[ii], "attrib");
    }
    ret = ret.replace(/attribute_no_init/g, "no_initializer");
    ret = ret.replace(/attribute_init/g, "initializer");
    return ret;
}

var base;
var object_class;

function check_hierarchy(classes){
    var parent_list = [];
    var s = new Set();
    /* This loop checks that no class is defined twice and constructs the
       list detailing parent-child pairs for later use
    */
    for (var ii = 0; ii < classes.length; ii++){
        if ( s.has(classes[ii].name.id.toString()) ){
            //TODO? better error message, name.line undefined for base class
            console.log("ERROR: " + classes[ii].name.line + ": Type-Check: Class "
                    + classes[ii].name.id.toString() + " redefined.");
            process.exit(1);
        }
        s.add(classes[ii].name.id.toString());
        if (classes[ii].name.id.toString() === "Object") continue;
        if (classes[ii].inherits){
            parent_list.push(classes[ii].inherits);
        } else {
            parent_list.push(object_class);
        }
        parent_list.push(classes[ii]);
    }
    pairs = ts.to_pairs(parent_list);
    subs = ts.get_ith(pairs, 1);
    supers = ts.get_ith(pairs, 0);
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

    function get_ancestry(class_obj){
        var ancestry = [];
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
    for (var ii = 0; ii < classes.length; ii++){
        var parents_of = get_ancestry(classes[ii]);
    }

    
};

function run(){
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
        var ast = rf.read_program(lines);
        //If there's such a thing as idiomatic javascript, this isn't it
        base = setup();
        object_class = base[3];
        ast.classes = ast.classes.concat(base);
        ast.classes.sort(function(a, b){
            if(a.name.id.toString() < b.name.id.toString()) return -1;
            if(a.name.id.toString() > b.name.id.toString()) return 1;
            return 0;
        });
        check_hierarchy(ast.classes);
        fs.writeFile(in_file.substr(0, in_file.lastIndexOf('.')) + '.cl-type'
            , out_class_map(ast.classes));
    });
}
run()
