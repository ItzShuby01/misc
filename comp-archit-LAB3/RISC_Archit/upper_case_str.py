import itertools


def read_line(s, buf_size):
    """Read line from input with buffer size limits."""
    assert "\n" in s, "input should have a newline character"
    line = "".join(itertools.takewhile(lambda x: x != "\n", s))

    if len(line) > buf_size - 1:
        return None, s[buf_size:]

    return line, s[len(line) + 1:]


def cstr(s, buf_size):
    """Make content for buffer with pascal string (default value for cell: `_`)."""
    assert len(s) + 1 <= buf_size
    buf = s + "\0" + ("_" * (buf_size - len(s) - 1))
    return "".join(itertools.takewhile(lambda c: c != "\0", s)), buf


def upper_case_cstr(s):
    """Convert a C string to upper case.

    - Result string should be represented as a correct C string.
    - Buffer size for the message -- `0x20`, starts from `0x00`.
    - End of input -- new line.
    - Initial buffer values -- `_`.

    Python example args:
        s (str): The input C string.

    Returns:
        tuple: A tuple containing the upper case string and an empty string.
    """
    line, rest = read_line(s, 0x20)
    if line is None:
        return [overflow_error_value], rest
    return cstr(line.upper(), 0x20)[0], rest


print(upper_case_cstr('Hello\n') == ('HELLO', ''))
# and mem[0..31]: 48 45 4c 4c 4f 00 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f
print(upper_case_cstr('world\n') == ('WORLD', ''))
# and mem[0..31]: 57 4f 52 4c 44 00 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f 5f
