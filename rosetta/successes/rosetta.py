import sys
lst = list( zip( *([iter([x.strip() for x in sys.stdin.readlines()])] * 2 )))
def solve(tasks, pairs, ans):
    if not tasks: 
        print(*ans, sep='\n')
        exit()
    if sorted(list(tasks - set([x[0] for x in pairs]))): solve(tasks - set(sorted(list(tasks - set([x[0] for x in pairs])))[0]), [x for x in pairs if x[1] != sorted(list(tasks - set([x[0] for x in pairs])))[0]], ans + [sorted(list(tasks - set([x[0] for x in pairs])))[0]] )
    else: print("cycle")
solve(set(sum(lst,())),lst,[])
