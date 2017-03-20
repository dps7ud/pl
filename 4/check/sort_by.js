function setup(){
    var classes = []
    var class_names = ["Bool", "IO", "Int", "Object", "String"];
    for (var ii = 0; ii < class_names.length; ii++){
        var cool_class = {};
        cool_class.name = class_names[ii];
        cool_class.inherits = false;
        cool_class.features = [];
        cool_class.toString = function(){
            return "Class " + this.name.toString();
        };
        classes.push(cool_class);
    }
    class_names = ["Other", "Classes", "Aaa", "AAA", "ABb"];
    for (var ii = 0; ii < class_names.length; ii++){
        var cool_class = {};
        cool_class.name = class_names[ii];
        cool_class.inherits = false;
        cool_class.features = [];
        cool_class.toString = function(){
            return "Class " + this.name.toString();
        };
        classes.push(cool_class);
    }
    return classes;
}

var by_name = function(a, b){
    var ret = 0;
    if (a.name.toString() < b.name.toString()) ret = -1;
    if (a.name.toString() > b.name.toString()) ret = 1;
    return ret;
}

var a = setup();
a.sort(by_name);
console.log(a);
