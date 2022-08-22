#!/bin/env python3

import sys

if __name__ == '__main__':
    p = sys.argv[1]

    with open(p, 'r') as f:
        lines = f.readlines()

    for i in range(len(lines)):
        s = "array_name[{}] = 32'h{};".format(i, lines[i].strip())
        print('{0:<60}\\'.format(s))
