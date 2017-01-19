import sys
with open('simp.txt', 'r') as f:
    contents = f.readlines()
lst = list( zip( *(  [iter(  [x.strip() for x in contents]  )]  * 2 )))
print(lst)
#lst = list( zip( *(  [iter(  [x.strip() for x in sys.stdin.readlines()]  )]  * 2 )))
def solve(tasks, pairs, ans):
#    print('\n\ntasks: ', tasks)
#    print('\n\npairs: ', pairs)
    #print('ans: \n', ans)
    #If not tasks... if not ans...
    tasks or (print(*ans, sep='\n') or exit())
    temp = sorted(list(tasks - set([x[0] for x in pairs])))
#    print('\n\ntemp: ', temp)
    #tasks - first task in temp (the element taken)
    #pairs - all pairs where pair[1] is not the element taken
    #ans   - ans + the element taken
    #If temp is empty, print cycle
#    print('element taken: ', temp[0])
#    print(temp[0] in tasks)
#    print('less: ', tasks - set(temp[0]))
#    input()
    solve(tasks.remove(temp[0]), [x for x in pairs if x[1] != temp[0]], ans + [temp[0]] ) if temp else print("cycle")
solve(set(sum(lst,())),lst,[])
