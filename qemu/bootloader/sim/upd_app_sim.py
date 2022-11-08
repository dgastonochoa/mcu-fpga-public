#!/usr/bin/env python3

import logging
import os

level = logging.INFO if 'LOG' in os.environ else logging.ERROR

FORMAT = '%(name)s :: %(levelname)-8s :: %(message)s'
logging.basicConfig(format=FORMAT)
logger = logging.getLogger('risc-v sim')
logger.setLevel(level)
logger.info('Logs enabled')


class Reg32:
    def __init__(self, idreg, val):
        self.id = idreg
        self.v = val


class Stack(list):
    def __init__(self, sp):
        super(Stack, self).__init__([-1] * 256)
        self.sp = sp

    def push(self, elem):
        return super(Stack, self).__setitem__(self.sp.v, elem)

    def pop(self):
        return super(Stack, self).__getitem__(self.sp.v)


x0 = Reg32(0, 0)
ra = Reg32(1, -1)
sp = Reg32(2, -1)
gp = Reg32(3, -1)
tp = Reg32(4, -1)
t0 = Reg32(5, -1)
t1 = Reg32(6, -1)
t2 = Reg32(7, -1)
s0 = Reg32(8, -1)
s1 = Reg32(9, -1)
a0 = Reg32(10, -1)
a1 = Reg32(11, -1)
a2 = Reg32(12, -1)
a3 = Reg32(13, -1)
a4 = Reg32(14, -1)
a5 = Reg32(15, -1)
a6 = Reg32(16, -1)
a7 = Reg32(17, -1)
s2 = Reg32(18, -1)
s3 = Reg32(19, -1)
s4 = Reg32(20, -1)
s5 = Reg32(21, -1)
s6 = Reg32(22, -1)
s7 = Reg32(23, -1)
s8 = Reg32(24, -1)
s9 = Reg32(25, -1)
s1 = Reg32(26, -1)
s1 = Reg32(27, -1)
t3 = Reg32(28, -1)
t4 = Reg32(29, -1)
t5 = Reg32(30, -1)
t6 = Reg32(31, -1)

stack = Stack(sp)

ESC_C = 0xff
SSI_BASE = 100
GPIO_BASE = 200


######
ST_IDLE = 0          # general idle
ST_CMD  = 1          # general cmd. received
ST_END  = 255        # general end (debug)
######

###### Write state machine consts
ST_W_ST = 2         # write start
ST_W_RC = 3         # write read char.
ST_W_RE = 4         # write escaped char. read
ST_W_RN = 5         # write normal char. read
######

###### Read state machine consts
ST_R_ST  = 6        # read start
ST_R_WRC = 7        # read write-read char.
######


STATES = [0] * 260
STATES[ST_IDLE]  = 'ST_IDLE'
STATES[ST_CMD]   = 'ST_CMD'
STATES[ST_END]   = 'ST_END'
STATES[ST_W_ST]  = 'ST_W_ST'
STATES[ST_W_RC]  = 'ST_W_RC'
STATES[ST_W_RE]  = 'ST_W_RE'
STATES[ST_W_RN]  = 'ST_W_RN'
STATES[ST_R_ST]  = 'ST_R_ST'
STATES[ST_R_WRC] = 'ST_R_WRC'

CMD_C = 2
CMD_W = 3
CMD_R = 4


###### Mocks:
SSI_RD_BUFF = [3, 0, 2, 4, 6, ESC_C, ESC_C, 8, 10, ESC_C, 12]
SSI_READ_IDX = 0

SSI_WD_BUFF = ['-'] * 20
SSI_WRITE_IDX = 0

MEMORY = ['-'] * 20

WFG_CALLS = 0

# Wait for GPIO
# a0 = GPIO base addr.
# a1 = level
def WFG():
    global WFG_CALLS

    assert a0.v == GPIO_BASE
    assert a1.v == 1
    WFG_CALLS -= 1
    logger.info('Remaining WFG calls {}'.format(WFG_CALLS))
    assert WFG_CALLS >= 0, WFG_CALLS


# Read from SPI
# a0 = SPI base addr
# a1 = value read
# a2 = error code
def RB():
    assert a0.v == SSI_BASE
    global SSI_READ_IDX
    a1.v = SSI_RD_BUFF[SSI_READ_IDX]
    SSI_READ_IDX += 1
    a2.v = 0
    logger.info('Read val {}'.format(a1.v))


# Write value in memory
# a0 = Mem. addr.
# a1 = value to store
# a0 = error code
def WVM():
    assert a0.v % 4 == 0
    global MEMORY
    MEMORY[int(a0.v / 4)] = a1.v
    logger.info('Stored val {} in {}'.format(a1.v, a0.v))
    a0.v = 0


# Send byte
# a0 = SPI base addr.
# a1 = [7:0] = byte
# a0 = error code
def SB():
    assert a0.v == SSI_BASE
    global SSI_WRITE_IDX
    SSI_WD_BUFF[SSI_WRITE_IDX] = a1.v
    SSI_WRITE_IDX += 1
    logger.info('Write val {}'.format(a1.v))
    return 0


# Read SPI buffer (without sending)
#
# a0 = SPI base addr.
# a1 = Value in SPI buffer
#
# a0 = error code
def RSB():
    assert a0.v == SSI_BASE
    global SSI_READ_IDX
    a1.v = SSI_RD_BUFF[SSI_READ_IDX]
    SSI_READ_IDX += 1
    logger.info('Read val {}'.format(a1.v))


# Read value from memory
# a0 = Memory pointer
# a1 = value read
#
# a0 = error code
def RVM():
    assert a0.v % 4 == 0
    global MEMORY
    a1.v = MEMORY[int(a0.v / 4)]
    logger.info('Read val. {} from mem. at {}'.format(a1.v, a0.v))
    a0.v = 0


def mocks_reset():
    global SSI_RD_BUFF
    global SSI_READ_IDX
    global SSI_WD_BUFF
    global SSI_WRITE_IDX
    global MEMORY
    global WFG_CALLS

    SSI_RD_BUFF = [3, 0, 2, 4, 6, ESC_C, ESC_C, 8, 10, ESC_C, 12]
    SSI_READ_IDX = 0
    SSI_WD_BUFF = ['-'] * 20
    SSI_WRITE_IDX = 0
    MEMORY = ['-'] * 20
    WFG_CALLS = 0
######


# Write-machine next state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
#
# ret:  a0 Error code
def WNS():
    _d_cs = s2.v

    a0.v = GPIO_BASE
    a1.v = 1

    if s2.v == ST_W_ST:
        WFG()
        s2.v = ST_W_RC

    elif s2.v == ST_W_RC:
        if s3.v == ESC_C:
            WFG()
            s2.v = ST_W_RE
        else:
            s2.v = ST_W_RN

    elif s2.v == ST_W_RE:
        if s3.v == ESC_C:
            s2.v = ST_W_RN
        else:
            assert s3.v == CMD_C
            s2.v = s5.v

    elif s2.v == ST_W_RN:
        WFG()
        s2.v = ST_W_RC

    elif s2.v == ST_END:
        a0.v = 0
        return

    else:
        assert False, s2.v

    logger.info('Changing state from {} to {}'.format(STATES[_d_cs], STATES[s2.v]))

    a0.v = 0


# Write-machine execute state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
#
# ret:  a0 Error code
def WES():
    if s2.v == ST_W_ST:
        s3.v = 0
        a0.v = 0

    elif s2.v == ST_W_RC:
        a0.v = SSI_BASE
        RB()
        a0.v = a2.v
        s3.v = a1.v

    elif s2.v == ST_W_RE:
        a0.v = SSI_BASE
        RB()
        a0.v = a2.v
        s3.v = a1.v

    elif s2.v == ST_W_RN:
        a0.v = s4.v
        a1.v = s3.v
        WVM()
        s4.v += 4

    elif s2.v == ST_END:
        a0.v = 0
        pass


# Read-machine next state
#
# glob: s2 Current machine state
# glob: s3 Last value read
#
# ret:  a0 Error code
def RNS():
    _d_cs = s2.v

    a0.v = GPIO_BASE
    a1.v = 1

    if s2.v == ST_R_ST:
        WFG()
        s2.v = ST_R_WRC

    elif s2.v == ST_R_WRC:
        if s3.v == CMD_C:
            s2.v = s6.v
        else:
            WFG()
            s2.v = ST_R_WRC

    elif s2.v == ST_END:
        a0.v = 0
        return

    else:
        assert False

    logger.info('Changing state from {} to {}'.format(STATES[_d_cs], STATES[s2.v]))


# Execute state: ST_R_WRC
#
# in:    a0 SSI base addr.
# out:   a2 Value read from SSI
# inout: a1 Memory pointer
#
# ret: a0 error code
def EX_ST_R_WRC():
    t0.v = a0.v         # save SSI base addr
    t1.v = a1.v         # save memory pointer
    a0.v = a1.v         # a0 = memory pointer
    RVM()               # a1 = read from memory
    a0.v = t0.v         # a0 = SSI base addr
    SB()                # send mem. read value over SSI
    a0.v = t0.v         # a0 = SSI base
    RSB()               # a1 = value read from SSI
    a2.v = a1.v         # a2 = value read from SSI
    a1.v = t1.v + 4     # a1 = memory pointer + 4


# Read-machine execute state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
#
# ret:  a0 Error code
def RES():
    if s2.v == ST_R_ST:
        s3.v = 0

    elif s2.v == ST_R_WRC:
        a0.v = SSI_BASE
        a1.v = s4.v
        EX_ST_R_WRC()
        s3.v = a2.v
        s4.v = a1.v

    elif s2.v == ST_END:
        a0.v = 0
        return

    else:
        assert False, s2.v


# General-machine next state
#
# glob: s2 Current machine state
# glob: s3 Last value read
#
# ret:  a0 Error code
def NS():
    _d_cs = s2.v

    a0.v = GPIO_BASE
    a1.v = 1

    if s2.v == ST_IDLE:
        WFG()
        s2.v = ST_CMD

    elif s2.v == ST_CMD and s3.v == CMD_W:
        s2.v = ST_W_ST

    elif s2.v == ST_CMD and s3.v == CMD_R:
        s2.v = ST_R_ST

    elif s2.v == ST_CMD and s3.v == CMD_C:
        s2.v = ST_END

    elif s2.v == ST_END:
        return

    elif s2.v >= ST_W_ST and s2.v <= ST_W_RN:
        WNS()
        return

    elif s2.v >= ST_R_ST and s2.v <= ST_R_WRC:
        RNS()
        return

    else:
        assert False, s2.v

    logger.info('Changing state from {} to {}'.format(STATES[_d_cs], STATES[s2.v]))


# General-machine execute state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
#
# ret:  a0 Error code
def ES():
    if s2.v == ST_IDLE:
        s4.v = 0
        s3.v = 0

    elif s2.v == ST_CMD:
        a0.v = SSI_BASE
        RB()
        s3.v = a1.v

    elif s2.v == ST_END:
        return

    elif s2.v >= ST_W_ST and s2.v <= ST_W_RN:
        WES()

    elif s2.v >= ST_R_ST and s2.v <= ST_R_WRC:
        RES()

    else:
        assert False, s2.v


def cpu_reset():
    x0.v = 0
    ra.v = -1
    sp.v = -1
    gp.v = -1
    tp.v = -1
    t0.v = -1
    t1.v = -1
    t2.v = -1
    a0.v = -1
    a1.v = -1
    a2.v = -1
    a3.v = -1
    a4.v = -1
    a5.v = -1
    a6.v = -1
    a7.v = -1
    s2.v = -1
    s3.v = -1
    s4.v = -1
    s5.v = -1
    s6.v = -1
    s7.v = -1
    s8.v = -1
    s9.v = -1
    s1.v = -1
    s1.v = -1
    t3.v = -1
    t4.v = -1
    t5.v = -1
    t6.v = -1

    global stack
    stack = Stack(sp)


def test_reset():
    cpu_reset()
    mocks_reset()

    s5.v = ST_END

    s2.v = ST_W_ST
    s3.v = 0
    s4.v = 0


# TODO better naming
def test_reset2():
    cpu_reset()
    mocks_reset()

    s6.v = ST_END

    s2.v = ST_R_ST
    s3.v = 0
    s4.v = 0


# TODO better naming
def test_reset3():
    cpu_reset()
    mocks_reset()
    s2.v = ST_IDLE
    s3.v = 0
    s4.v = 0


def tests_cpu_write():
    global SSI_RD_BUFF
    global WFG_CALLS
    global MEMORY
    global SSI_WD_BUFF

    # Test escape works
    test_reset()
    SSI_RD_BUFF = [3, 0, 2, 4, 6, 5, 6, 8, 10, ESC_C, CMD_C]
    WFG_CALLS = len(SSI_RD_BUFF)
    for i in range(0, 100):
        WES()
        WNS()
    assert MEMORY[0:10] == [3, 0, 2, 4, 6, 5, 6, 8, 10, '-'], MEMORY[0:10]
    assert WFG_CALLS == 0, WFG_CALLS

    logger.info('-' * 50)

    # Test escape + escape works
    test_reset()
    SSI_RD_BUFF = [3, 0, 2, 4, 6, ESC_C, ESC_C, 8, 10, ESC_C, CMD_C]
    WFG_CALLS = len(SSI_RD_BUFF)
    for i in range(0, 100):
        WES()
        WNS()
    assert MEMORY[0:9] == [3, 0, 2, 4, 6, ESC_C, 8, 10, '-'], MEMORY[0:9]
    assert WFG_CALLS == 0, WFG_CALLS

    logger.info('-' * 50)

    # Test writin at an addr != 0 works
    test_reset()
    s4.v = 8
    SSI_RD_BUFF = [3, 0, 2, 4, 6, 5, 6, 8, 10, ESC_C, CMD_C]
    WFG_CALLS = len(SSI_RD_BUFF)
    for i in range(0, 100):
        WES()
        WNS()
    assert MEMORY[0:12] == ['-', '-', 3, 0, 2, 4, 6, 5, 6, 8, 10, '-'], MEMORY[0:10]
    assert WFG_CALLS == 0, WFG_CALLS

    logger.info('-' * 50)

    # Test escape before finish works
    test_reset()
    SSI_RD_BUFF = [3, 0, 2, 4, 6, 5, ESC_C, CMD_C, 10, ESC_C, CMD_C]
    WFG_CALLS = 8
    for i in range(0, 100):
        WES()
        WNS()
    assert MEMORY[0:10] == [3, 0, 2, 4, 6, 5, '-', '-', '-', '-'], MEMORY[0:10]
    assert WFG_CALLS == 0, WFG_CALLS

    logger.info('-' * 50)


def tests_cpu_read():
    global SSI_RD_BUFF
    global WFG_CALLS
    global MEMORY
    global SSI_WD_BUFF

    # Test escape works
    test_reset2()
    MEMORY =      [5, 1, 2, 3, 4, 7, 1]
    SSI_RD_BUFF = [0, 0, 0, 0, 0, 0, CMD_C]
    WFG_CALLS = 7
    for i in range(0, 100):
        RES()
        RNS()
    assert SSI_WD_BUFF[0:9] == [5, 1, 2, 3, 4, 7, 1, '-', '-'], SSI_WD_BUFF[0:9]
    assert WFG_CALLS == 0, WFG_CALLS

    # Test escape before finish works
    test_reset2()
    MEMORY =     [5, 1, 2, 3, 4, 7, 1,     9, 8]
    SSI_RD_BUFF = [0, 0, 0, 0, 0, 0, CMD_C, 0, 0]
    WFG_CALLS = 7
    for i in range(0, 100):
        RES()
        RNS()
    assert SSI_WD_BUFF[0:9] == [5, 1, 2, 3, 4, 7, 1, '-', '-'], SSI_WD_BUFF[0:9]
    assert WFG_CALLS == 0, WFG_CALLS

    # Test reading from != 0 works
    test_reset2()
    s4.v = 8
    MEMORY =     [5, 1, 2, 3, 4, 7, 1,     9, 8]
    SSI_RD_BUFF = [     0, 0, 0, 0, CMD_C, 0, 0]
    WFG_CALLS = 5
    for i in range(0, 100):
        RES()
        RNS()
    assert SSI_WD_BUFF[0:7] == [2, 3, 4, 7, 1, '-', '-'], SSI_WD_BUFF[0:7]
    assert WFG_CALLS == 0, WFG_CALLS


def tests_cpu_gen():
    global SSI_RD_BUFF
    global WFG_CALLS
    global MEMORY
    global SSI_WD_BUFF

    # Test read only
    test_reset3()
    s6.v = ST_END
    SSI_RD_BUFF = [CMD_R, 0, 0, 0, 0, 0, 0, CMD_C]
    MEMORY =      [       5, 1, 2, 3, 4, 7, 1]
    WFG_CALLS = len(SSI_RD_BUFF)
    for i in range(0, 100):
        ES()
        NS()
    assert SSI_WD_BUFF[0:8] == [5, 1, 2, 3, 4, 7, 1, '-'], SSI_WD_BUFF[0:8]
    assert WFG_CALLS == 0, WFG_CALLS

    # Test write only
    test_reset3()
    s5.v = ST_END
    SSI_RD_BUFF = [CMD_W, 3, 0, 2, 4, 6, 5, 6, 8, 10, ESC_C, CMD_C]
    WFG_CALLS = len(SSI_RD_BUFF)
    for i in range(0, 100):
        ES()
        NS()
    assert MEMORY[0:10] == [3, 0, 2, 4, 6, 5, 6, 8, 10, '-'], MEMORY[0:10]
    assert WFG_CALLS == 0, WFG_CALLS

    # Test write and then read
    test_reset3()
    s5.v = ST_IDLE
    s6.v = ST_END
    SSI_RD_BUFF = [CMD_W, 3, 0, 2, 4, 6, 5, 6, 8, 10,    ESC_C, CMD_C,
                   CMD_R, 0, 0, 0, 0, 0, 0, 0, 0, CMD_C]
    WFG_CALLS = len(SSI_RD_BUFF)
    for i in range(0, 100):
        ES()
        NS()
    assert MEMORY[0:10] == [3, 0, 2, 4, 6, 5, 6, 8, 10, '-'], MEMORY[0:10]
    assert SSI_WD_BUFF[0:10] == [3, 0, 2, 4, 6, 5, 6, 8, 10, '-'], SSI_WD_BUFF[0:10]
    assert WFG_CALLS == 0, WFG_CALLS


def tests_wns_works():
    global WFG_CALLS

    test_reset2()
    s5.v = ST_IDLE
    WFG_CALLS = 1e3
    s2.v = ST_W_ST


    s3.v = 0
    WNS()
    assert s2.v == ST_W_RC

    s3.v = ESC_C
    WNS()
    assert s2.v == ST_W_RE

    s3.v = ESC_C
    WNS()
    assert s2.v == ST_W_RN

    WNS()
    assert s2.v == ST_W_RC

    s3.v = 25
    WNS()
    assert s2.v == ST_W_RN

    WNS()
    assert s2.v == ST_W_RC

    s3.v = ESC_C
    WNS()
    assert s2.v == ST_W_RE

    s3.v = CMD_C
    WNS()
    assert s2.v == ST_IDLE


def tests_rns_works():
    global WFG_CALLS

    test_reset2()
    s6.v = ST_IDLE
    WFG_CALLS = 1e3
    s2.v = ST_R_ST


    RNS()
    assert s2.v == ST_R_WRC

    s3.v = 0
    RNS()
    assert s2.v == ST_R_WRC

    s3.v = 0
    RNS()
    assert s2.v == ST_R_WRC

    s3.v = CMD_C
    RNS()
    assert s2.v == ST_IDLE, STATES[s2.v]


def tests_ns_works():
    global WFG_CALLS

    test_reset2()
    s5.v = ST_IDLE
    s6.v = ST_IDLE
    WFG_CALLS = 1e3
    s2.v = ST_IDLE

    NS()
    assert s2.v == ST_CMD

    s3.v = CMD_W
    NS()
    assert s2.v == ST_W_ST

    s3.v = 0
    NS()
    assert s2.v == ST_W_RC

    s3.v = ESC_C
    NS()
    assert s2.v == ST_W_RE

    s3.v = ESC_C
    NS()
    assert s2.v == ST_W_RN

    NS()
    assert s2.v == ST_W_RC

    s3.v = 25
    NS()
    assert s2.v == ST_W_RN

    NS()
    assert s2.v == ST_W_RC

    s3.v = ESC_C
    NS()
    assert s2.v == ST_W_RE

    s3.v = CMD_C
    NS()
    assert s2.v == ST_IDLE

    NS()
    assert s2.v == ST_CMD

    s3.v = CMD_R
    NS()
    assert s2.v == ST_R_ST

    RNS()
    assert s2.v == ST_R_WRC

    s3.v = 0
    RNS()
    assert s2.v == ST_R_WRC

    s3.v = 0
    RNS()
    assert s2.v == ST_R_WRC

    s3.v = CMD_C
    RNS()
    assert s2.v == ST_IDLE, STATES[s2.v]


if __name__ == '__main__':
    tests_wns_works()
    tests_rns_works()
    tests_ns_works()
    tests_cpu_write()
    tests_cpu_read()
    tests_cpu_gen()
    print('SUCCESS')
