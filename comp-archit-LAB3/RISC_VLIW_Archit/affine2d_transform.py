def affine2d_transform(*xs):
    """Input: first word N, then N pairs: x, y.

    Output for every pair: u = 3*x + 2*y + 5, v = -x + 4*y - 7.
    """
    n = xs[0]
    if n < 0:
        return [-1]

    result = []
    for i in range(n):
        x = xs[1 + 2 * i]
        y = xs[2 + 2 * i]
        u = 3 * x + 2 * y + 5
        v = -x + 4 * y - 7
        if (
            u < -0x80000000
            or u > 0x7FFFFFFF
            or v < -0x80000000
            or v > 0x7FFFFFFF
        ):
            return [0xCCCCCCCC]
        result.extend([u, v])

    return result


# assert affine2d_transform(0) == []
# assert affine2d_transform(1, 1, 2) == [12, 0]
# assert affine2d_transform(2, 0, 0, 3, -1) == [5, -7, 12, -14]
# assert affine2d_transform(3, -2, 5, 10, 0, -1, -1) == [9, 15, 35, -17, 0, -10]

print(affine2d_transform(0))
print(affine2d_transform(1, 1, 2))
print(affine2d_transform(2, 0, 0, 3, -1))
print(affine2d_transform(3, -2, 5, 10, 0, -1, -1))
