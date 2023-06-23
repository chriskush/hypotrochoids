import math

def lcm(a, b):
    return abs(a*b) // math.gcd(a, b)

for r in range(72, 513):
    c = 0
    d = []
    for g in range(1, r):
        p = lcm(r, g) / g
        if (p in [2, 3, 4, 5, 6, 7, 8, 12]):
            d.append(str(g) + "=" + str(int(p)))
            c += 1
    if (c > 14):
      print(str(r) + ": " + str(c) + " (" + ",".join(d) + ")")
