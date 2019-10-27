#include "ud_utils.h"

int     ud_ut_byte_cmp_ctr(void *a, void *b, size_t n)
{
    char *p_a = (char *)a;
    char *p_b = (char *)b;

    for (ud_ut_count i = 0; i < n; ++i, ++p_a, ++p_b)
        if (*p_a != *p_b) return (*p_a - *p_b);
    return (0);
}