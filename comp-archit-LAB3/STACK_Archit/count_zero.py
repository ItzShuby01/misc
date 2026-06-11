def count_zero(n):
    """Count the number of zeros in the binary representation of a number"""
    count = 0
    for _ in range(32):
        count += 0 if n & 1 else 1
        n >>= 1
    return count


print(count_zero(5))
print(count_zero(7))
print(count_zero(247923789))
