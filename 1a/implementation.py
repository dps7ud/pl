from math import sqrt

def c_to_f(celc):
    return celc * (1.8) + 32
    # Celsius -> Fahrenheit
    


def split_tip(price, n):
    ''' Split total 'price' of check 'n' ways 
       return price with %20 tip split n ways.
       if n < 1 or price < 0: return None

    '''
    price *= 1.2
    return price / n

def triangle_area(a, b, c):
    ''' If s1,s2, and s3 form a valid triangle, 
       return the area of this trianlge
       otherwise, return None
    '''
    sides = {a, b, c}
    m = max(sides)
    if sum(sides) - 2 * m <= 0:

    s = (a + b + c)/2
    return sqrt(s * (s - a) * (s - b) * (s - c))


def repeat(func, arg, n):
    ''' Given unary function f, argument arg and int n,
       return f^n(arg)
    '''
    for ii in range(n):
        arg = func(arg)
    return arg


def list_length(lst):
    #Return the number of items in list l
    return len(lst)
