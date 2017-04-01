var ts = require("./toposort.js");
var SymbolTable = require("./symboltable.js").SymbolTable;

var pairs = []
var subs = []
var supers = []
var full_ancestry = []

function imap(parent_list){
    pairs = ts.to_pairs(parent_list);
    subs = ts.get_ith(pairs, 1);
    supers = ts.get_ith(pairs, 0);
    full_ancestry = [];
    var full_object_class = parent_list.filter( (item) => {
        return item.name.id === "Object";
    })[0];
    object_class = [full_object_class.name.id, full_object_class.features.map( (item) => {
        item.def = full_object_class.name.id;
        return item;
    })];

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
 
    //  Create an array that holds, for each class, an inheritance chain from
    // the class to Object
    for (var ii = 0; ii < subs.length; ii++){
        full_ancestry.push(get_ancestry(subs[ii]))
    }
    var imp_map = [];
    var attribute_map = [];
    //  Using the classes' inheritance chain, we construct the implementation map.
    for (var ii = 0; ii < full_ancestry.length; ii++){
        class_obj = full_ancestry[ii][0];
        var methods = [];
        var attribs = [];
        for (var jj = full_ancestry[ii].length - 1; jj >= 0; jj--){
            //  For every parent class, push class methods onto the list, 
            // noting in which class the method was defined
            var jj_methods = full_ancestry[ii][jj].features.filter( (item) => {
                return item.kind === "method"
            }).map( (item) => {
                item.def = full_ancestry[ii][jj].name.id;
                return item;
            });

            var jj_attributes = full_ancestry[ii][jj].features.filter( (item) => {
                return item.kind !== "method"
            }).map( (item) => {
                item.def = full_ancestry[ii][jj].name.id;
                return item;
            });

            attribs = attribs.concat(jj_attributes);

            //  Keep track of a set of method names already defined
            var methods_defined = new Set(methods.map( (item) => {
                return item.name.id;
            }));

            //  Add everything not already defined
            methods = methods.concat( jj_methods.filter( (item) => {
                return !methods_defined.has(item.name.id);
            }));

            //  Replace everythin already defined
            var to_replace = jj_methods.filter( (item) => {
                return methods_defined.has(item.name.id);
            });

            for (var kk = 0; kk < to_replace.length; kk++){
                var index = methods.map( (item) => {
                    return item.name.id;
                }).indexOf(to_replace[kk].name.id);
                methods[index] = to_replace[kk];
            }
        }
        attribute_map.push([class_obj.name.id, attribs]);
        imp_map.push([class_obj.name.id, methods])
    }

    //  Since Object doesn't appear in our lists of superclasses and subclasses,
    // we manually push it into the implementation map and resort.
    // Also put it in the full ancestry tree
    imp_map.push(object_class);
    full_ancestry.push([full_object_class]);
    attribute_map.push(["Object", []]);

    //TODO: Implement
    //  With imp_map built, lets get all the strings
    imp_map.sort( (a,b) => {return (a[0]<b[0] ? -1 : (a[0]>b[0] ? 1 : 0))});
    attribute_map.sort( (a,b) => {return (a[0]<b[0] ? -1 : (a[0]>b[0] ? 1 : 0))});
    check_class(attribute_map, imp_map);
    var im_string = "implementation_map\n";
    im_string += list_to_string(imp_map, imap_class_to_string);
    return im_string;
}

function check_class(attribute_map, imp_map){
    var methods = new SymbolTable();
    var objects = new SymbolTable();
    objects.add("self", "SELF_TYPE");
    objects.add("SELF_TYPE", "SELF_TYPE");

    //  All classes should be available identifiers
    // and have their own type
    for (var ii = 0; ii < imp_map.length; ii++){
        objects.add(imp_map[ii][0], imp_map[ii][0]);
        for (var jj = 0; jj < imp_map[ii][1].length; jj++){
            var method = imp_map[ii][1][jj];
            var type_list = method.formals.map( (item) => {
                return item.f_type.id;
            });
            type_list.push(method.ret_type.id);
            methods.add(imp_map[ii][0] + "," + method.name.id, type_list );
        }
    }
    for (var ii = 0; ii < imp_map.length; ii++){
        //  Add all local attributes to table
        for (var jj = 0; jj < attribute_map[ii][1].length; jj++){
            var local_attrib = attribute_map[ii][1][jj];
            objects.add(local_attrib.name.id, local_attrib.f_type.id);
        }

        //  Typecheck exprs of all initalized attributes
        // Class ii attribute jj
        for (var jj = 0; jj < attribute_map[ii][1].length; jj++){
            var check_attrib = attribute_map[ii][1][jj]
            if (check_attrib.kind === "attribute_init") {
                var actual = typecheck(check_attrib.init, objects, methods, imp_map[ii][0]);
                    //TODO check conformity not equality
                if (!conforms(actual, check_attrib.f_type.id, 
                            attribute_map[ii][0], 'init attribs')){
                    var msg = actual + " does not conform to " + check_attrib.f_type.id
                        + " in initialized attribute";
                    put_error(check_attrib.name.line, msg);
                }
            }
        }

        for (var jj = 0; jj < imp_map[ii][1].length; jj++){
            //  Class ii method jj
            var to_check = imp_map[ii][1][jj];
            if (typeof(to_check.body) !== 'string'){
                //  Add parameters to env to check method body
                for (var kk = 0; kk < to_check.formals.length; kk++){
//                  WTF is *formal* and why is it defined
                    objects.add(to_check.formals[kk].name.id, to_check.formals[kk].f_type.id);
                }
                to_check.body.type = typecheck(to_check.body, objects, methods, imp_map[ii][0]);
//                console.log(to_check.body.type, to_check.ret_type.id);
                var conformity = conforms(to_check.body.type, to_check.ret_type.id
                        , imp_map[ii][0], "174");
                if (!conformity){
                    var msg = to_check.body.type + " does not conform to "
                        + to_check.ret_type.id + " in method " + to_check.name.id
                    put_error(to_check.name.line, msg);
                }
                for (var kk = 0; kk < to_check.formals.length; kk++){
                    objects.remove(to_check.formals[kk].name.id);
                }
            }
        }
    }
};


function typecheck(exp, objects, methods, st){
    if (exp.type !== ''){
        return exp.type;
    }
    switch(exp.kind) {
        case "assign":
//            exp.variable = read_id(lines);
//            exp.assign_exp = read_exp(lines);
            if (objects.mem(exp.variable.id)){
                exp.type = objects.find(exp.variable.id);
                exp.assign_exp.type = typecheck(exp.assign_exp, objects, methods, st)
            } else {
                put_error(exp.variable.line, 'unbound identifier ' + exp.variable.id);
            }

            if (!conforms(exp.assign_exp.type, exp.type, st, "assign")){
                var msg = exp.assign_exp.type + " does not conform to " + exp.type
                    + " in assignment";
                put_error(exp.line, msg);
            }

            return exp.assign_exp.type;
            break;
        case "dynamic_dispatch":
//            exp.e = read_exp(lines);
//            exp.method = read_id(lines);
//            exp.args = read_list(lines, read_exp);
            exp.e.type = typecheck(exp.e, objects, methods, st);
            var temp_type = exp.e.type
            if (exp.e.type === "SELF_TYPE"){
                temp_type = st;
            }
            if (!methods.mem(temp_type + ',' + exp.method.id)){
                var msg = "unknown method " + exp.method.id
                    + " in dispatch on " + temp_type
                put_error(exp.line, msg);
            } else {
                var type_list = methods.find(temp_type+','+exp.method.id);
                var nargs = type_list.length - 1;
                if (nargs !== exp.args.length){
                    var msg = "wrong number of actual arguments (" + exp.args.length + " vs. " 
                        + nargs + ")";
                    put_error(exp.line, msg);
                }
                for (var ii = 0; ii < nargs; ii++){
                    exp.args[ii].type = typecheck(exp.args[ii], objects, methods, st);
                    if (! conforms(exp.args[ii].type, type_list[ii], st)){
                        var msg = "argument #" + (ii + 1) + " type " + exp.args[ii].type
                            + " does not conform to formal type " + type_list[ii];
                        put_error(exp.args[ii].line, msg)
                    }
                }
                exp.type = type_list[type_list.length - 1];
                if (exp.type === "SELF_TYPE"){
                    return exp.e.type
                }
                return exp.type
            }
            break;
        case "static_dispatch":
            exp.e.type = typecheck(exp.e, objects, methods, st);
            if (! conforms(exp.e.type, exp.d_type.id, st)){
                var msg = exp.e.type + " does not conform to " + exp.d_type.id
                    + " in static dispatch";
                put_error(exp.line, msg)
            }
            if (!methods.mem(exp.e.type+','+exp.method.id)){
                var msg = "unknown method " + exp.method.id
                    + " in dispatch on " + exp.e.type
                put_error(exp.line, msg);
            } else {
                var type_list = methods.find(exp.e.type+','+exp.method.id);
                var nargs = type_list.length - 1;
                if (nargs !== exp.args.length){
                    var msg = "wrong number of actual arguments (" + exp.args.length + " vs. " 
                        + nargs + ")";
                    put_error(exp.line, msg);
                }
                for (var ii = 0; ii < nargs; ii++){
                    exp.args[ii].type = typecheck(exp.args[ii], objects, methods, st);
                    if (! conforms(exp.args[ii].type, type_list[ii], st)){
                        var msg = "argument #" + (ii + 1) + " type " + exp.args[ii].type
                            + " does not conform to formal type " + type_list[ii];
                        put_error(exp.args[ii].line, msg)
                    }
                }
                exp.type = type_list[type_list.length - 1];
                return exp.type
            }
//            exp.e = read_exp(lines);
//            exp.d_type = read_id(lines);
//            exp.method = read_id(lines);
//            exp.args = read_list(lines, read_exp);
            break;
        case "self_dispatch":
            if (!methods.mem(st+','+exp.method.id)){
                var msg = "unknown method " + exp.method.id
                    + " in dispatch on " + st
                put_error(exp.line, msg);
            } else {
                var type_list = methods.find(st+','+exp.method.id);
                var nargs = type_list.length - 1;
                if (nargs !== exp.args.length){
                    var msg = "wrong number of actual arguments (" + exp.args.length + " vs. " 
                        + nargs + ")";
                    put_error(exp.line, msg);
                }
                for (var ii = 0; ii < nargs; ii++){
                    exp.args[ii].type = typecheck(exp.args[ii], objects, methods, st);
                    if (! conforms(exp.args[ii].type, type_list[ii],st)){
                        var msg = "argument #" + (ii + 1) + " type " + exp.args[ii].type
                            + " does not conform to formal type " + type_list[ii];
                        put_error(exp.args[ii].line, msg)
                    }
                }
                exp.type = type_list[type_list.length - 1];
                return exp.type
            }

//            exp.method = read_id(lines);
//            exp.args = read_list(lines, read_exp);
            break;
        case "plus":
        case "times":
        case "minus":
        case "divide":
            exp.x.type = typecheck(exp.x, objects, methods, st);
            exp.y.type = typecheck(exp.y, objects, methods, st);
            if (exp.x.type !== "Int" || exp.y.type !== "Int"){
                put_error(exp.x.line, "arithmatic on " + exp.x.type + " " + exp.y.type 
                        + " instead of Ints");
            }
            return "Int";
            break;
        case "lt":
        case "le":
        case "eq":
            exp.x.type = typecheck(exp.x, objects, methods, st);
            exp.y.type = typecheck(exp.y, objects, methods, st);
            if (exp.x.type === "String" || exp.x.type === "Bool" || exp.x.type === "Int"){
                if (exp.x.type !== exp.y.type){
                    var msg = "comparison between " + exp.x.type + " and " + exp.y.type;
                    put_error(exp.x.line, msg);
                }
            }
            return "Bool"
            break;
        case "while":
//            exp.x = read_exp(lines);
//            exp.y = read_exp(lines);
            exp.x.type = typecheck(exp.x, objects, methods, st);
            if (exp.x.type !== "Bool"){
                var msg = "predicate has type " + exp.x.type + " instead of Bool"
                put_error(exp.x.line, msg);
            }
            exp.y.type = typecheck(exp.y, objects, methods, st);
            return "Object"
            break;
        case "string":
//            exp.type = "String";
//            exp.constant = lines.shift();
            return "String";
            break;
        case "integer":
//            exp.type = "Int";
//            exp.constant = lines.shift();
            return "Int";
            break;
        case "if":
//            exp.pred = read_exp(lines);
//            exp.then = read_exp(lines);
//            exp.otherwise = read_exp(lines);
            exp.pred.type = typecheck(exp.pred, objects, methods, st);
            if (exp.pred.type !== "Bool"){
                var msg = "predicate has type " + exp.pred.type + " instead of Bool"
                put_error(exp.pred.line, msg);
            }
            exp.then.type = typecheck(exp.then, objects, methods, st);
            exp.otherwise.type = typecheck(exp.otherwise, objects, methods, st);
            exp.type = lub(exp.then.type, exp.otherwise.type, st);
            return exp.type
            break;
        case "block":
//            exp.body = read_list(lines, read_exp);
            for (var ii = 0; ii < exp.body.length; ii++){
                exp.body[ii].type = typecheck(exp.body[ii], objects, methods, st);
            }
            return exp.body[exp.body.length - 1].type;
            break;
        case "new":
            //TODO resolve self_type
            var temp_type = exp.type;
            if (objects.mem(exp.ident.id)){
                temp_type = objects.find(exp.ident.id)
            } else {
                put_error(exp.ident.line, 'unbound identifier ' + exp.ident.id);
            }
            if (exp.type === "SELF_TYPE"){
                temp_type = st;
            }
            return temp_type;
            break;
        case "identifier":
//            exp.ident = read_id(lines);
            if (objects.mem(exp.ident.id)){
                exp.type = objects.find(exp.ident.id)
            } else {
                put_error(exp.ident.line, 'unbound identifier ' + exp.ident.id);
            }
            return exp.type;
            break;
        case "isvoid":
            exp.e.type = typecheck(exp.e, objects, methods, st);
            return "Bool"
            break;
        case "not":
            exp.e.type = typecheck(exp.e, objects, methods, st);
            if (exp.e.type !== "Bool"){
                var msg = "not applied to type " + exp.e.type + " instead of Bool";
                put_error(exp.e.line, msg);
            } else {
                return "Bool"
            }
            break;
        case "negate":
//            exp.e = read_exp(lines);
            exp.e.type = typecheck(exp.e, objects, methods, st);
            if (exp.e.type !== "Int"){
                var msg = "negate applied to type " + exp.e.type + " instead of Int";
                put_error(exp.e.line, msg);
            } else {
                return "Int"
            }
            break;
        case "true":
        case "false":
//            exp.type = "Bool";
            return "Bool";
            break;
        case "let":
            for (var ii = 0; ii < exp.list.length; ii++){
                binding = exp.list[ii];
                if (binding.kind === "let_binding_init"){
                    binding.value.type = typecheck(binding.value, objects, methods, st);
                    if (!conforms( binding.value.type, binding.type.id, st,"let")){
                        var msg = "initializer type " + binding.value.type 
                            + " does not conform to type " + binding.type.id;
                        put_error(binding.value.line, msg);
                    }
                }
                objects.add(binding.variable.id, binding.type.id);
            }
            exp.body.type = typecheck(exp.body, objects, methods, st);
            for (var ii = 0; ii < exp.list.length; ii++){
                objects.remove(exp.list[ii].variable.id);
            }
            return exp.body.type
//            exp.list = read_list(lines, read_binding);
//            exp.body = read_exp(lines);
//    binding.kind = lines.shift();
//    binding.variable = read_id(lines);
//    binding.type = read_id(lines);
//    if (binding.kind === "let_binding_init"){
//        binding.value = read_exp(lines);
//    }
            break;
        case "case":

//            exp.e = read_exp(lines);
//            exp.cases = read_list(lines, read_case);
            exp.e.type = typecheck(exp.e, objects, methods, st);
            var type_list = [];
            var type_set = new Set();
            for (var ii = 0; ii < exp.cases.length; ii++){
                case_obj = exp.cases[ii];
                if (case_obj.v_type.id === "SELF_TYPE"){
                    var msg = "using SELF_TYPE as a case branch type is not allowed";
                    put_error(case_obj.v_type.line, msg);
                }
                objects.add(case_obj.variable.id, case_obj.v_type.id);
                case_obj.body.type = typecheck(case_obj.body, objects, methods, st);
                objects.remove(case_obj.variable.id);
                if (type_set.has(case_obj.v_type.id)){
                    var msg = "case branch type " + case_obj.v_type.id + " is bound twice";
                    put_error(case_obj.body.line, msg);
                }
                type_set.add(case_obj.v_type.id);
                type_list.push(case_obj.body.type);
            }
    //case_obj.variable = read_id(lines);
    //case_obj.v_type = read_id(lines);
    //case_obj.body = read_exp(lines);
            return type_list.reduce((a,b) =>{
                var l = lub(a,b,st);
                return l;} // for debugging, TODO: just use lub
                , type_list[0]);
            break;
    }
};

function conforms(class_a, class_b, st_context, info){
//    console.log(class_a, class_b)
//    console.log(st_context)
    if (class_a === "SELF_TYPE")
        class_a = st_context
    if (class_b === "SELF_TYPE")
        class_b = st_context
    var supers_of_a = new Set(full_ancestry.filter( (item) =>{
        return item[0].name.id === class_a;
    })[0].map( (item) => {return item.name.id}));
    return supers_of_a.has(class_b);
}

function lub(class_a, class_b, st_context){
//    console.log(class_a, class_b)
    if (class_a === "SELF_TYPE" && class_b === "SELF_TYPE")
        return "SELF_TYPE"
    if (class_a === "SELF_TYPE")
        class_a = st_context
    if (class_b === "SELF_TYPE")
        class_b = st_context
    var super_set_a = new Set(full_ancestry.filter( (item) =>{
        return item[0].name.id === class_a;
    })[0].map( (item) => {return item.name.id}));

    var super_list_b = full_ancestry.filter( (item) =>{
        return item[0].name.id === class_b;
    })[0];
    for (var ii = 0; ii < super_list_b.length; ii++){
        if (super_set_a.has(super_list_b[ii].name.id)){
            return super_list_b[ii].name.id;
        }
    }
}

function list_to_string(list, to_str_func){
    var str = list.length + '\n';
    for (var ii = 0; ii < list.length; ii++){
        str += to_str_func(list[ii]);
    }
    return str;
}

//  For imap, classobj is really just [class_name_string, method_list]
function imap_class_to_string(classobj){
    var str = classobj[0] + '\n';
    str += list_to_string(classobj[1], imap_method_to_string);
    return str;
}

function imap_method_to_string(method){
    var str = method.name.id + '\n';
    str += list_to_string(method.formals , imap_formal_to_string);
    str += method.def + '\n';
    str += method.body.toString();
    return str;
}

function imap_formal_to_string(formal){
    return formal.name.id + '\n';
}

function pmap(parent_list){
    //  parent_list is a list of classes that looks like:
    //[parent0, child0,...]
    str = 'parent_map' + '\n' + parent_list.length/2 + '\n';
    while(parent_list.length > 0){
        superclass = parent_list.shift();
        subclass = parent_list.shift();
        str += subclass.name.id + '\n'
        str += superclass.name.id + '\n'
    }
    return str;
}

function put_error(line, message){
    str = "ERROR: " + line + ": Type-Check: " + message;
    console.log(str);
    process.exit(1);
}

exports.pmap = pmap;
exports.imap = imap;
