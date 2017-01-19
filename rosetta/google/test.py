
def check_diff(length):
    s = set()
    s.add('A' * length)
    s.add('B' * length)
    s = s - set('B' * length)
    print(type(list(s)[0]))
    return ('B' * length) in s

def check(length):
    s = set()
    s.add('A' * length)
    s.add('B' * length)
    s.remove('B' * length)
    return ('B' * length) in s

for ii in range(80):
    if not check(ii):
        print(ii)
