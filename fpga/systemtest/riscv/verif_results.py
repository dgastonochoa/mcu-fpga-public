#!/usr/bin/env python3

import argparse

from expected_results import exp_res


def twoscomp(n, nbits=32):
    sign = '1' if n < 0 else '0'
    x = format(n, '{}{}b'.format(sign, nbits))
    y = ''.join(['0' if i == '1' else '1' for i in x])
    return format(int(y, 2) + 1, '{}{}b'.format(sign, nbits))


def twos(n):
    assert(n < 0)
    n *= -1
    return int(twoscomp(n), 2)


def verify_results(path):
    with open(path, 'r') as f:
        lines = f.readlines()

    words = []
    for i in range(0, len(lines) - 3, 4):
        b0 = int(lines[i], 16)
        b1 = int(lines[i + 1], 16)
        b2 = int(lines[i + 2], 16)
        b3 = int(lines[i + 3], 16)

        word = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
        words.append(word)

    assert len(exp_res) == len(words), 'Unexpected number of words. Expected: {}, found: {}'.format(
        len(exp_res), len(words))

    for i in range(0, len(words)):
        val = exp_res[i]
        if (val < 0):
            val = twos(val)
        assert val == words[i], '{}: {} == {}'.format(i, val, words[i])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Verify physical FPGA RISC-V CPU results')
    parser.add_argument('results_file', type=str, help='File containing the results')
    args = parser.parse_args()

    verify_results(args.results_file)
