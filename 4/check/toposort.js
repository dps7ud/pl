
//  Since JS was designed servents of evil, we need to define our 
// own comparator to sort a list of numbers as, get this... NUMBERS
function by_number(a, b){
    return a - b;
}

//  Gets ith column of a 2D list 
function ith (ary, i){
    ans = [];
    for (var ii = 0; ii < ary.length; ii++){
        ans.push(ary[ii][i]);
    }
    return ans;
}

//  Zips together array[::2] and array[1::2]
function to_pairs(array){
    var pairs = [];
    for (var ii = 0; ii < array.length; ii+=2){
        if (array[ii+1] !== undefined){
            pairs.push ([array[ii], array[ii+1]]);
        }
    }
    return pairs;
}

//  Topological sort
function topo(tasks, pairs, ans) {
    if(tasks.length > 0){
        var prereqs = ith(pairs,0);
        var todo = tasks.filter( (item) => {
            var b = !prereqs.includes(item);
            return b
        })
        if (todo.length <= 0){ return false;}
        todo.sort();
        var taken = todo[0];
        tasks.splice(tasks.indexOf(taken), 1);
        var new_pairs = pairs.filter( (item)=> {
            return item[1] !== taken;
        })
        ans.push(taken)
        return topo(tasks, new_pairs, ans);
    } else {return true;}
}
exports.toposort = topo;
exports.to_pairs = to_pairs;
exports.get_ith= ith;
