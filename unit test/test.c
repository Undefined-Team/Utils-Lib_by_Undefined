# include <ud_utils.h>
# include <stdio.h>

static int     ud_ut_byte_cmp_ctr(void *a, void *b, size_t n)
{
    char *p_a = (char *)a;
    char *p_b = (char *)b;

    for (ud_ut_count i = 0; i < n; ++i, ++p_a, ++p_b)
        if (*p_a != *p_b) return (*p_a - *p_b);
    return (0);
}

int main(void)
{
    int a = 2;
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(a == 2);
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_byte(a), "00000000000000000000000000000010", 8 * 4 * sizeof(char)));
    return (0);
}