var fs = require('fs');
var ts = require("./toposort.js");

function put_error(line, message){
    var str = "ERROR: " + line + ": Type-Check: " + message;
    console.log(str);
    process.exit(1);
};

/* Process input*/
function read_list(lines, read_func){
    var list = [];
    var nelements = lines.shift();
    for(var ii = 0; ii < nelements; ii++){
        list.push(read_func(lines));
    }
    return list;
}

function read_program(lines){
    var program = {};
    program.classes = read_list(lines, read_class);
    program.toString = function(){
        return list_to_string(this.classes) + "\n"
    };
    return program;
}

function list_to_string(list){
    var str = "";
    str += list.length;
    if(list.length > 0){
        str += "\n";
        str += list.map(function(e) {
            return e.toString();
        }).join("\n");
    }
    return str;
}

function read_class(lines){
    var class_obj = {};
    class_obj.name = read_id(lines);
    if(lines.shift() === "no_inherits"){
        class_obj.inherits = false;
    } else {
        class_obj.inherits = read_id(lines);
    }
    class_obj.features = read_list(lines, read_feature);
    class_obj.toString = function(){
        var str = this.name.toString();
        for (var ii = 0; ii < this.features.length; ii++){
            str += '\n';
            str += this.features[ii].toString();
        }
        return str;
    };
    return class_obj;
}

function read_id(lines){
    var ident = {};
    ident.line = lines.shift();
    ident.id = lines.shift();
    ident.toString = function(){
        return this.id.toString();
    };
    return ident;
}

function read_feature(lines){
    var feature = {};
    feature.kind = lines.shift();
    switch (feature.kind){
        case "attribute_no_init":
            feature.name = read_id(lines);
            feature.f_type = read_id(lines);
            feature.toString = function(){
                var str = this.kind + '\n';
                str += this.name.toString() + '\n';
                str += this.f_type.toString();
                return str;
            }
            break;
        case "attribute_init":
            feature.name = read_id(lines);
            feature.f_type = read_id(lines);
            feature.init = read_exp(lines);
            feature.toString = function(){
                var str = this.kind + '\n';
                str += this.name + '\n';
                str += this.f_type + '\n';
                str += this.init.toString();
                return str;
            }
            break;
        case "method":
            feature.name = read_id(lines);
            feature.formals = read_list(lines, read_formal);
            feature.ret_type = read_id(lines);
            feature.body = read_exp(lines);
            break;
    }
    return feature;
}

function read_formal(lines){
    var formal = {};
    formal.name = read_id(lines);
    formal.f_type = read_id(lines);
    return formal;
}

function read_exp(lines){
    var exp = {};
    exp.line = lines.shift();
    exp.kind = lines.shift();
    exp.str_repr = exp.line + '\n' + exp.kind;
    switch(exp.kind) {
        case "assign":
            exp.variable = read_id(lines);
            exp.assign_exp = read_exp(lines);
            exp.str_repr += '\n' + exp.variable.toString();
            exp.str_repr += exp.assign_exp.toString();
            break;
        case "dynamic_dispatch":
            exp.e = read_exp(lines);
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);
            break;
        case "static_dispatch":
            exp.e = read_exp(lines);
            exp.d_type = read_id(lines);
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);
            break;
        case "self_dispatch":
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);
            break;
        case "plus":
        case "times":
        case "minus":
        case "divide":
        case "lt":
        case "le":
        case "eq":
            exp.x = read_exp(lines);
            exp.y = read_exp(lines);
            break;
        case "string":
        case "integer":
            exp.constant = lines.shift();
            exp.str_repr += '\n' + exp.constant;
            break;
        case "if":
        case "while":
        case "block":
        case "new":
        case "isvoid":
        case "not":
        case "negate":
        case "identifier":
        case "true":
        case "false":
            console.log("UNIMPLEMENTED EXPR TYPE: " + exp.kind);
            break;
    }
    exp.toString = function(){return exp.str_repr};
    return exp;
}

function setup(){
    var classes = [];
    var class_names = ["Bool", "IO", "Int", "Object", "String"];
    for (var ii = 0; ii < class_names.length; ii++){
        var cool_class = {};
        cool_class.name = class_names[ii];
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
    }
/*
    class_obj.features = read_list(lines, read_feature);

    case "method";:
        feature.name = read_id(lines);
        feature.formals = read_list(lines, read_formal);
        feature.ret_type = read_id(lines);
        feature.body = read_exp(lines);
    var formal = {};
    formal.name = read_id(lines);
    formal.f_type = read_id(lines);
    return formal;
*/
        switch(cool_class.name){
            case "IO":
                out_string = {};
                out_string.name = "out_string";
                formal = {};
                formal.name = "x";
                formal.f_type = "String";
                out_string.formals = [formal];
                out_string.ret_type = "SELF_TYPE";
                out_string.kind = "method";

                out_int = {};
                out_int.name = "out_int";
                formal = {};
                formal.name = "x";
                formal.f_type = "Int";

                out_int.formals = [formal];
                out_int.ret_type = "SELF_TYPE";
                out_int.kind = "method";

                in_string = {};
                in_string.name = "in_string";
                in_string.formals = [];
                in_string.ret_type = "String";
                in_string.kind = "method";

                in_int = {};
                in_int.name = "in_int";
                in_int.formals = [];
                in_int.ret_type = "Int";
                in_int.kind = "method";

                cool_class.features = [out_string, out_int, in_string, in_int];
                break;
            case "Object":
                abort = {};
                abort.name = "abort";
                abort.formals = [];
                abort.ret_type = "Object";
                abort.kind = "method";

                type_name = {};
                type_name.name = "type_name";
                type_name.formals = [];
                type_name.ret_type = "String";
                type_name.kind = "method";

                copy = {};
                copy.name = "copy";
                copy.formals = [];
                copy.ret_type = "SELF_TYPE";
                copy.kind = "method";
                cool_class.features = [abort, type_name, copy];
                break;
            case "String":
                length = {}
                length.name = "length";
                length.formals = [];
                length.ret_type = "Int";
                length.kind = "method";

                concat = {}
                concat.name = "concat";
                formal = {};
                formal.name = "s";
                formal.f_type = "String";
                concat.formals = [formal];
                concat.ret_type = "String";
                concat.kind = "method";

                substr = {}
                substr.name = "substr";

                formal = {};
                formal.name = "i";
                formal.f_type = "Int";
                substr.formals = [formal];
                formal = {};
                formal.name = "l";
                formal.f_type = "Int";
                substr.formals.push(formal);

                substr.ret_type = "String";
                concat.kind = "method";
                cool_class.features = [length, concat, substr];
                break;
            default:
                break;
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
        ret += classes[ii].name.toString();
        ret += out_feature_list(classes[ii], "attrib");
    }
    ret = ret.replace("attribute_no_init", "no_initializer");
    ret = ret.replace("attribute_init", "initializer");
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
        if ( s.has(classes[ii].name.toString()) ){
            //TODO? better error message, name.line undefined for base class
            console.log("ERROR: " + classes[ii].name.line + ": Type-Check: Class "
                    + classes[ii].name.toString() + " redefined.");
            process.exit(1);
        }
        s.add(classes[ii].name.toString());
        if (classes[ii].name === "Object") continue;
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
    console.log(supers);
    for (var ii = 0; ii < supers.length; ii++){
        // Checks for undefined superclass
        if (supers[ii].name === undefined){
            var find = classes.filter(function(item){
                return item.name.toString() === supers[ii].id.toString();
            });
            if (find.length > 0) {
                supers[ii] = find[0];
            } else {
                console.log("ERROR: " + subs[ii].inherits.line + ": Type-Check: Class " 
                        + subs[ii].name.toString()
                        + " inherits from unknown class " + supers[ii].id.toString() );
                process.exit(1);
            }
        }
        // Checks for inherit from protected class
        if (cant_inherit.has(supers[ii].name.toString())){
            console.log("ERROR: " + subs[ii].inherits.line + ": Type-Check: Class "
                    + subs[ii].name.toString() + " inherits from " + supers[ii].name.toString());
            process.exit(1);
        }
    }
    var names = parent_list.map(function(item){
        // God, I hate javascript
        if (item.name !== undefined)
            return item.name.toString();
        else
            return item.id;
    });
    if( !ts.toposort(Array.from(new Set(names)), ts.to_pairs(names), [])){
        //TODO? better error, get cycle from ts.topo
        console.log("ERROR: 0: Type-Check: Inheritance cycle: ");
        process.exit(1);
    }

    function get_ancestry(class_obj){
        var ancestry = [class_obj];
        var has_more = true;
        while (has_more){
            var index = -1;
            for(var ii = 0; ii < subs.length; ii++){
                if (subs[ii].name.toString() === class_obj.name.toString()){
                    index = ii;
                    break;
                }
            }
            class_obj = supers[ii];
            ancestry.push(class_obj);
            has_more = (index !== -1)
        }
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
        var ast = read_program(lines);
        //If there's such a thing as idiomatic javascript, this isn't it
        base = setup();
        object_class = base[3];
        ast.classes = ast.classes.concat(base);
        ast.classes.sort(function(a, b){
            if(a.name.toString() < b.name.toString()) return -1;
            if(a.name.toString() > b.name.toString()) return 1;
            return 0;
        });
        check_hierarchy(ast.classes);
        fs.writeFile(in_file.substr(0, in_file.lastIndexOf('.')) + '.cl-type'
            , out_class_map(ast.classes));
    });
}
run()
