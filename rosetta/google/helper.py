#lst = []
#with open('doc.txt','r') as fil:
#    lst = fil.readlines()
#lst = [x.strip() for x in lst if x != '']
#print(lst)
##with open('adj.txt','w') as wr:
#    for line in lst:
#        wr.write(line + '\n')
with open('adj.txt', 'r') as fin:
    lst = [x.strip() for x in fin.readlines()]
print(lst)
out = []
ii = 65
d = dict()
for item in lst:
    if item in d:
        out.append(d[item])
    else:
        d[item] = chr(ii) * 78
        out.append(d[item])
        ii += 1
print(len(max(d.keys(), key=len)))
with open('simp.txt', 'w') as fout:
    for item in out:
        fout.write(item + '\n')
