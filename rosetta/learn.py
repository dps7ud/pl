# This file explores the following line of code:
# lst = list( zip( *(  [iter(  [x.strip() for x in sys.stdin.readlines()]  )]  * 2 )))
import sys
a = [x.strip() for x in sys.stdin.readlines()] #list
b = iter(  a  ) #list iterator
c = [b] #list of list iterators (len = 1)
d = c  * 2 #list of list iterators (len = 2)
e = zip(*( d ))
f = list(e)

l = [a, b, c, d, e, f]
for i, item in enumerate(l):
    print(chr(i + 65))
    print(item)
    print("type: " + str(type(item)) + '\n')
