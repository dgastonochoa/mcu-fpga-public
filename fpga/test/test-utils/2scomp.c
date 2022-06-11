#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

int main(int argc, char *argv[])
{
    int x = (int)strtol(argv[1], NULL, 0);
    if (x == 0) {
        printf("error %d\n", __LINE__);
        return -1;
    }

    if (argc > 2) {
        if (argv[2][0] == '+') {
            int y = (int)strtol(argv[3], NULL, 0);
            x += y;
            if (y == 0) {
                printf("error %d\n", __LINE__);
                return -1;
            }
        } else if (argv[2][0] == '-') {
            int y = (int)strtol(argv[3], NULL, 0);
            x -= y;
            if (y == 0) {
                printf("error %d\n", __LINE__);
                return -1;
            }
        }
    }

    printf("dec:\t%d\n", x);
    printf("hex:\t0x%x\n", x);
    printf("2scomp:\t0x%x\n", ~x + 1);
    printf("neg:\t0x%x\n", (short)(((short)x) * -1));

    return 0;
}