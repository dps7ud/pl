//    tasks = Array.from(new Set(lines));
//    pairs = to_pairs(lines);
//    ans = [];
//    topo(tasks, pairs, ans);

function by_number(a, b){
    return a - b;
}

function ith (ary, i){
    ans = [];
    for (var ii = 0; ii < ary.length; ii++){
        ans.push(ary[ii][i]);
    }
    return ans;
}

function to_pairs(array){
    var pairs = [];
    for (var ii = 0; ii < array.length; ii+=2){
        if (array[ii+1] !== undefined){
            pairs.push ([array[ii], array[ii+1]]);
        }
    }
    return pairs;
}

function topo(tasks, pairs, ans) {
    if(tasks.length > 0){
        var prereqs = ith(pairs,0);
        var todo = tasks.filter( (item) => {
            var b = !prereqs.includes(item);
            return b
        })
        if (todo.length <= 0){ console.log("cycle"); return 0;}
        todo.sort();
        var taken = todo[0];
        tasks.splice(tasks.indexOf(taken), 1);
        var new_pairs = pairs.filter( (item)=> {
            return item[1] !== taken;
        })
        ans.push(taken)
        return topo(tasks, new_pairs, ans);
    } else {
        for (var ii = 0; ii < ans.length; ii++){
            console.log(ans[ii]);
        } 
        return 0;
    }
}
exports.toposort = topo;
exports.to_pairs = to_pairs;
