#!/usr/bin/env python3
"""Rewrite absolute build-machine paths inside a Mach-O so the shipped binary
does not reveal the CI workspace (project name, runner user).

Paths only appear in Swift `#file` literals used by assertion messages, so an
in-place, same-length replacement is safe. The binary is re-signed afterwards
by Theos (`ldid`), which recomputes the signature.

Usage: strip_source_paths.py <macho> [<macho> ...]
"""
import re
import sys

ASCII = re.compile(rb'/Users/[A-Za-z0-9_.\-]+/[!-&(-~]*')
UTF16 = re.compile(rb'(?:/\x00U\x00s\x00e\x00r\x00s\x00/\x00)'
                   rb'(?:[A-Za-z0-9_.\-\x00])+'
                   rb'(?:[!-&(-~\x00])*')


def neutral(n, wide=False):
    if wide:
        raw = ('/tmp/' + 'x' * max(0, n - 5)).encode('ascii')
        return b''.join(bytes([c, 0]) for c in raw)[:n]
    return ('/tmp/' + 'x' * max(0, n - 5)).encode('ascii')[:n]


def strip(data):
    out = bytearray(data)
    count = 0

    for m in ASCII.finditer(data):
        s, e = m.span()
        rep = neutral(e - s)
        out[s:e] = rep
        count += 1

    for m in UTF16.finditer(data):
        s, e = m.span()
        if (e - s) % 2:
            continue
        rep = neutral(e - s, wide=True)
        out[s:e] = rep
        count += 1

    return bytes(out), count


def main():
    total = 0
    for path in sys.argv[1:]:
        data = open(path, 'rb').read()
        new, n = strip(data)
        if n:
            open(path, 'wb').write(new)
        print('%s: %d path(s) rewritten' % (path, n))
        total += n
    return 0


if __name__ == '__main__':
    sys.exit(main())
