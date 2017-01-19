# This file explores the following line of code:
# lst = list( zip( *(  [iter(  [x.strip() for x in sys.stdin.readlines()]  )]  * 2 )))
import sys
six = [x.strip() for x in sys.stdin.readlines()]
five = iter(  six  )
four = [five]
three = four  * 2 
#print(three)
two = zip(*( four * 2  ))
zero = list(two )

l = [six, five, four, three, two, zero]
for item in l:
    print()
    print(item)
    print("type: " + str(type(l)))
