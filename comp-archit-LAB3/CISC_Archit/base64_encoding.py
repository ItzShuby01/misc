import base64
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


def base64_encoding(input):
    """Encode input string to base64.

    - Result string should be represented as a correct C string.
    - Buffer size for the encoded message -- `0x40`, starts from `0x00`.
    - End of input -- new line.

    Python example args:
        input (str): The input string containing data to encode.

    Returns:
        tuple: A tuple containing the base64 encoded string and the remaining input.
    """
    line, rest = read_line(input, 0x40)
    if line is None:
        return [overflow_error_value], rest

    encoded_bytes = base64.b64encode(line.encode("utf-8"))
    encoded_str = encoded_bytes.decode("ascii")

    if len(encoded_str) + 1 > 0x40:  # +1 for null terminator
        return [overflow_error_value], rest

    return cstr(encoded_str, 0x40)[0], rest


print(base64_encoding('Hello\n'))
