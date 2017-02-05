import sys
lst = list( zip( *(  [iter(  [x.strip() for x in sys.stdin.readlines()]  )] * 2  )))
def solve(tasks, pairs, ans):
    tasks or (print(*ans,sep='\n') or exit())
    solve(tasks - set([(sorted(list(tasks - set([x[0] for x in pairs]))))[0]]), [x for x in pairs if x[1] != (sorted(list(tasks - set([x[0] for x in pairs]))))[0]], ans + [(sorted(list(tasks - set([x[0] for x in pairs]))))[0]] ) if (sorted(list(tasks - set([x[0] for x in pairs])))) else print("cycle")
solve(set(sum(lst,())),lst,[])

"""
The code has been golfed to achive a minimal number of lines. We will 'unpack' line by line below.

1. import sys
    imports sys.

2. lst = list( zip( *(  [iter(  [x.strip() for x in sys.stdin.readlines()]  )]  * 2 )))

    i. [x.strip() for x in sys.stdin.readlines()]
        is the list of trimmed input lines.

    ii. iter(i)
        is an iterator object over the list i.

    iii. [ii] * 2
        is a list consisting of two references to the same iterator object.

    iv. zip( *(iii) )
        is a zip object. What are we zipping? Why, an iterator and itself, of course.

    v. lst = list(iv)
        is the list for of the resulting zip.

3. def solve(tasks, pairs, ans):
    Defining our function, we accept a set of tasks, a list of task dependencies and a list with
    which we will construct our solution.

4. tasks or (print(*ans,sep='\n') or exit())
    Making use of python's short circuit evaluation, if no tasks remain, we have a solution
    and will print such, seperated by newlines and then exit.

5. (sorted(list(tasks - set([x[0] for x in pairs])))) = sorted(list(tasks - set([x[0] for x in pairs])))
    i. set([x[0] for x in pairs]) is the set of tasks that have prerequiset tasks.
    ii. list(tasks - i) is the list form of the complement of i, i.e., tasks that are doable.
    iii. (sorted(list(tasks - set([x[0] for x in pairs])))) = sorted(ii) is an alphabetic list of doable tasks

6. solve(tasks - set([(sorted(list(tasks - set([x[0] for x in pairs]))))[0]]), [x for x in pairs if x[1] != (sorted(list(tasks - set([x[0] for x in pairs]))))[0]], ans + [(sorted(list(tasks - set([x[0] for x in pairs]))))[0]] ) if (sorted(list(tasks - set([x[0] for x in pairs])))) else print("cycle")

    i. (sorted(list(tasks - set([x[0] for x in pairs]))))[0] 
        represents the unique correct choice of task.

    ii. tasks - set([(sorted(list(tasks - set([x[0] for x in pairs]))))[0]]) 
        are the tasks remaining now that we have selected (sorted(list(tasks - set([x[0] for x in pairs]))))[0]. Note that set((sorted(list(tasks - set([x[0] for x in pairs]))))[0]) 
        will give the set of characters in (sorted(list(tasks - set([x[0] for x in pairs]))))[0], hence set([(sorted(list(tasks - set([x[0] for x in pairs]))))[0]]).

    iii. [x for x in pairs if x[1] != (sorted(list(tasks - set([x[0] for x in pairs]))))[0]] 
        is the list of task dependence relationships that do not have (sorted(list(tasks - set([x[0] for x in pairs]))))[0] as a prerequisit.

    iv. ans + [(sorted(list(tasks - set([x[0] for x in pairs]))))[0]]
        is the updated answer.

    v. if (sorted(list(tasks - set([x[0] for x in pairs])))) else print("cycle")
        checks if (sorted(list(tasks - set([x[0] for x in pairs])))) is empty. If so, print cycle, otherwise, calculate solve(ii,iii,iv).

7. solve(set(sum(lst,())),lst,[])
    is our base case.
"""
