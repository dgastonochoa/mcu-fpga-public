#include <stdint.h>
#include <stdbool.h>

#include "test/qemu_io.h"
#include "test/bootloader_test_stdlib.h"
#include "test/bootloader_test_utils.h"

static char buff[256] = {0};

int __test_assert_impl(int ln, bool res, const char* expr)
{
    if (!res) {
        int2ansi(ln, buff);
        puts(buff);
        puts(": Error ");
        puts(expr);
        puts("\n");
        return -1;
    }
    return 0;
}
