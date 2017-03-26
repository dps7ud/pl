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
    for (var ii = 0; ii < list.length; ii++){
        str += '\n' + list[ii].toString();
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
        return ident.line + '\n' + ident.id;
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
                var str = 'no_initializer\n';
                str += this.name.id.toString() + '\n';
                str += this.f_type.id.toString();
                return str;
            }
            break;
        case "attribute_init":
            feature.name = read_id(lines);
            feature.f_type = read_id(lines);
            feature.init = read_exp(lines);
            feature.toString = function(){
                var str = 'initializer\n';
                str += this.name.id + '\n';
                str += this.f_type.id.toString() + '\n';
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
    exp.str_repr = exp.line + '\n' + exp.kind + '\n';
    switch(exp.kind) {
        case "assign":
            exp.variable = read_id(lines);
            exp.assign_exp = read_exp(lines);
            exp.str_repr += exp.variable.toString() + '\n';
            exp.str_repr += exp.assign_exp.toString();
            break;
        case "dynamic_dispatch":
            exp.e = read_exp(lines);
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);

            exp.str_repr += exp.e.toString() + '\n';
            exp.str_repr += exp.method.toString() + '\n';
            exp.str_repr += list_to_string(exp.args);
            break;
        case "static_dispatch":
            exp.e = read_exp(lines);
            exp.d_type = read_id(lines);
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);

            exp.str_repr += exp.e.toString() + '\n';
            exp.str_repr += exp.d_type.toString() + '\n';
            exp.str_repr += exp.method.toString() + '\n';
            exp.str_repr += list_to_string(exp.args);
            break;
        case "self_dispatch":
            exp.method = read_id(lines);
            exp.args = read_list(lines, read_exp);

            exp.str_repr += exp.method.toString() + '\n';
            exp.str_repr += list_to_string(exp.args);
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
            exp.str_repr += exp.x.toString() + '\n';
            exp.str_repr += exp.y.toString();
            break;
        case "string":
        case "integer":
            exp.constant = lines.shift();
            exp.str_repr += exp.constant;
            break;
        case "if":
            exp.pred = read_exp(lines);
            exp.then = read_exp(lines);
            exp.otherwise = read_exp(lines);
            exp.str_repr += exp.pred.toString() + '\n';
            exp.str_repr += exp.then.toString() + '\n';
            exp.str_repr += exp.otherwise.toString();
            break;
        case "block":
            exp.body = read_list(lines, read_exp);
            exp.str_repr += list_to_string(exp.body);
            break;
        case "new":
        case "identifier":
            exp.ident = read_id(lines);
            exp.str_repr += exp.ident.toString();
            break;
        case "isvoid":
        case "not":
        case "negate":
            exp.e = read_exp(lines);
            exp.str_repr += exp.e.toString();
            break;
        case "true":
        case "false":
            exp.str_repr = exp.str_repr.substring(0, exp.str_repr.length -1);
            break;
        case "let":
            exp.list = read_list(lines, read_binding);
            exp.body = read_exp(lines);
            exp.str_repr += list_to_string(exp.list) + '\n';
            exp.str_repr += exp.body.toString();
            break;
        case "case":
            exp.e = read_exp(lines);
            exp.cases = read_list(lines, read_case);
            exp.str_repr += exp.e.toString() + '\n';
            exp.str_repr += list_to_string(exp.cases);
            break;
        default:
            console.log("FAILURE: unimplemented expression type " + exp.kind);
            break;
    }
    exp.toString = function(){return exp.str_repr};
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
        var str = binding.kind + '\n' + binding.variable.toString() + '\n' 
            + binding.type.toString();
        if (binding.kind === "let_binding_init"){
            str += '\n' + binding.value.toString();
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
        var str = this.variable.toString() + '\n';
        str += this.v_type.toString() + '\n';
        str += this.body.toString();
        return str;
    };
    return case_obj;
}


exports.read_program = read_program;
