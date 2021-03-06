var fs = require('fs')
if (process.argv.length !== 3){
    console.log("Need a file");
    process.exit(1);
}

var in_file = process.argv[2]
fs.readFile(in_file, "utf-8", (err, data) => {
    if (err){
        console.log("Error opening file\n");
        process.exit(1);
    }
    var lines = data.split("\n");
    var len = lines.length
    for (var ii = 0; ii < len; ii++){
        console.log(lines[ii])
    }
    var stdin = process.openStdin();
    lines.splice(lines.indexOf(""), 1);
    tasks = Array.from(new Set(lines));
    pairs = to_pairs(lines);
    ans = [];
    topo(tasks, pairs, ans);
});

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
        } /*else {
        }*/
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
        tasks.splice(tasks.indexOf(taken));
        var new_pairs = pairs.filter( (item)=> {
            return item[0] !== taken;
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

//tasks = Array.from(new Set(lines)); //pairs = to_pairs(lines)
//ans = []

/*
def solve(tasks, pairs, ans):
    tasks or (print(*ans, sep='\n') or exit())
    temp = sorted(list(tasks - set([x[0] for x in pairs])))
    solve(tasks - set([temp[0]]), [x for x in pairs if x[1] != temp[0]], 
        ans + [temp[0]] ) if temp else print("cycle")
*/















