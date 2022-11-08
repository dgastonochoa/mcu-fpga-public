#ifndef BOOTLOADER_TEST_UTILS_H
#define BOOTLOADER_TEST_UTILS_H

#define    TEST_ASSERT(bool_expr)  \
    __test_assert_impl(__LINE__, bool_expr, #bool_expr)

int __test_assert_impl(int ln, bool res, const char* expr);

#endif // BOOTLOADER_TEST_UTILS_H