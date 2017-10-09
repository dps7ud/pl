//  This file contains functions used to deserialize our input file
// All fairly self-documenting and boring

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
        return list_to_string(this.classes.filter( (item) => {
            // Turns out we don't want to list builtin classes in our AAST
            return !(["Bool", "IO", "Int", "Object", "String"].includes(item.name.id));
        }));
    };
    return program;
}

function list_to_string(list){
    var str = "";
    str += list.length + '\n';
    for (var ii = 0; ii < list.length; ii++){
        str += list[ii].toString();
    }
    return str;
}

function read_class(lines){
    var class_obj = {};
    class_obj.name = read_id(lines);
    class_obj.kind = lines.shift();
    if(class_obj.kind === "no_inherits"){
        class_obj.inherits = false;
    } else {
        class_obj.inherits = read_id(lines);
    }
    class_obj.features = read_list(lines, read_feature);
    class_obj.toString = function(){
        var str = this.name.toString();

        if (class_obj.inherits){
            str += "inherits\n";
            str += class_obj.inherits.toString();
        } else {
            str += "no_inherits\n"
        }
        str += list_to_string(this.features);
        return str;
    }
    return class_obj;
}

function read_id(lines){
    var ident = {};
    ident.line = lines.shift();
    ident.id = lines.shift();
    ident.toString = function(){
        return ident.line + '\n' + ident.id + '\n';
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
                str += this.name.toString();
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
                str += this.name.toString();
                str += this.f_type.toString();
                str += this.init.toString(); 
                return str;
            }
            break;
        case "method":
            feature.name = read_id(lines);
            feature.formals = read_list(lines, read_formal);
            feature.ret_type = read_id(lines);
            feature.body = read_exp(lines);
            feature.toString = function(){
                var str = 'method\n';
                str += this.name.toString();
                str += list_to_string(this.formals);
                str += this.ret_type.toString();
                str += this.body.toString();
                return str;
            }
            break;
    }
    return feature;
}

function read_formal(lines){
    var formal = {};
    formal.name = read_id(lines);
    formal.f_type = read_id(lines);
    formal.toString = function(){
        return this.name.toString() + this.f_type.toString();
    }
    return formal;
}

function read_exp(lines){
    var exp = {};
    exp.line = lines.shift();
    exp.kind = lines.shift();
    exp.type = '';
    switch(exp.kind) {
        case "assign":
            exp.variable = read_id(lines);
            exp.assign_exp = read_exp(lines);

            exp.toString = function() {
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.variable.toString() 
                    + exp.assign_exp.toString();
            }
            break;
        case "dynamic_dispatch":
            exp.e = read_exp(lines);
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);

            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.e.toString()
                    + exp.method.toString()
                    + list_to_string(exp.args);
            };
            break;
        case "static_dispatch":
            exp.e = read_exp(lines);
            exp.d_type = read_id(lines);
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);

            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.e.toString()
                    + exp.d_type.toString()
                    + exp.method.toString()
                    + list_to_string(exp.args);
            };
            break;
        case "self_dispatch":
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);

            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.method.toString()
                    + list_to_string(exp.args);
            };
            break;
        case "plus":
        case "times":
        case "minus":
        case "divide":
        case "lt":
        case "le":
        case "eq":
        case "while":
            exp.x = read_exp(lines);
            exp.y = read_exp(lines);
            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.x.toString()
                    + exp.y.toString();
            };
            break;
        case "string":
            exp.constant = lines.shift();
            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.constant + '\n'
            };
            break;
        case "integer":
            exp.constant = lines.shift();
            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.constant + '\n'
            };
            break;
        case "if":
            exp.pred = read_exp(lines);
            exp.then = read_exp(lines);
            exp.otherwise = read_exp(lines);
            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.pred.toString()
                    + exp.then.toString()
                    + exp.otherwise.toString();
            };
            break;
        case "block":
            exp.body = read_list(lines, read_exp);
            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + list_to_string(exp.body);
            };
            break;
        case "new":
        case "identifier":
            exp.ident = read_id(lines);
            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.ident.toString();
            };
            break;
        case "isvoid":
        case "not":
        case "negate":
            exp.e = read_exp(lines);
            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.e.toString();
            };
            exp.str_repr += exp.e.toString();
            break;
        case "true":
        case "false":
            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
            };
            break;
        case "let":
            exp.list = read_list(lines, read_binding);
            exp.body = read_exp(lines);

            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + list_to_string(exp.list)
                    + exp.body.toString();
            };
            break;
        case "case":
            exp.e = read_exp(lines);
            exp.cases = read_list(lines, read_case);

            exp.toString = () => { 
                return exp.line + '\n'
                    + exp.type + '\n'
                    + exp.kind + '\n'
                    + exp.e.toString()
                    + list_to_string(exp.cases);
            };
            break;
        default:
            console.log("FAILURE: unimplemented expression type " + exp.kind);
            break;
    }
    return exp;
}

function read_binding(lines){
    var binding = {};
    binding.kind = lines.shift();
    binding.variable = read_id(lines);
    binding.type = read_id(lines);
    if (binding.kind === "let_binding_init"){
        binding.value = read_exp(lines);
    }
    binding.toString = function(){
        var str = this.kind + '\n'
            + this.variable.toString() 
            + this.type.toString();
        if (this.kind === "let_binding_init"){
            str += this.value.toString();
        }
        return str;
    }
    return binding;
}

function read_case(lines){
    case_obj = {};
    case_obj.variable = read_id(lines);
    case_obj.v_type = read_id(lines);
    case_obj.body = read_exp(lines);
    case_obj.toString = function(){
        var str = this.variable.toString()
        str += this.v_type.toString();
        str += this.body.toString();
        return str;
    };
    return case_obj;
}

exports.read_program = read_program;
