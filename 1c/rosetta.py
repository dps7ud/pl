import sys
lst = list( zip( *(  [iter(  [x.strip() for x in sys.stdin.readlines()]  )]  * 2 )))
def solve(tasks, pairs, ans):
    tasks or (print(*ans,sep='\n') or exit())
    temp = sorted(list(tasks - set([x[0] for x in pairs])))
    solve(tasks - set([temp[0]]), [x for x in pairs if x[1] != temp[0]], ans + [temp[0]] ) if temp else print("cycle")
solve(set(sum(lst,())),lst,[])
