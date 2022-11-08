#!/bin/env python3

import sys

if __name__ == '__main__':
    p = sys.argv[1]

    with open(p, 'r') as f:
        lines = f.readlines()

    print('#include <stdint.h>')
    print('')
    print('const uint32_t program[] = {')
    for i in range(len(lines)):
        s = "0x{}".format(lines[i].strip())
        if i < (len(lines) - 1):
            print('    {0},'.format(s))
        else:
            print('    {0}'.format(s))

    print('};')
    print('')
    print('const uint32_t program_size_words = sizeof(program) / sizeof(*program);')
    print('')
