def gcd(a, b):
    """Find the greatest common divisor (GCD)"""
    while b != 0:
        a, b = b, a % b
    return [abs(a)]


print(gcd(48, 18))
print(gcd(56, 98))
