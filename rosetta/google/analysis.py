import works
d = dict()
lst = []
with open('doc.txt','r') as fil:
    lst = fil.readlines()
for i,line in enumerate(lst):
    lst[i] = line.strip()
    print(lst[i])
print(lst)
lst = [x for x in lst if x != '']
singles = lst
s = set(lst)
lst = list(zip(lst[0::2],lst[1::2]))
d = dict()
for item in s:
    d[item] = set()
for i,item in enumerate(lst):
    d[item[0]].add(i)
    d[item[1]].add(i)
print('\n\n\n')
print(d)
for k,v in d.items():
    print(k)
    print(v)
