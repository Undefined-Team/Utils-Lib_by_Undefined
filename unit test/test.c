# include <ud_utils.h>
# include <stdio.h>

static int     ud_ut_byte_cmp(void *a, void *b, size_t n)
{
    char *p_a = (char *)a;
    char *p_b = (char *)b;

    for (ud_ut_count i = 0; i < n; ++i, ++p_a, ++p_b)
        if (*p_a != *p_b) return (*p_a - *p_b);
    return (0);
}

int main(void)
{
    int a = 3;
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_bin(a), "00000000000000000000000000000011", 8 * 4 * sizeof(char)));
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_bin(++a), "00000000000000000000000000000100", 8 * 4 * sizeof(char)));
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_bin(2), "00000000000000000000000000000010", 8 * 4 * sizeof(char)));
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_bin(2147483647), "01111111111111111111111111111111", 8 * 4 * sizeof(char)));

    int b = -2147483647 - 1;
    int c = -2147483648;
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_bin(-2147483647 - 1), "10000000000000000000000000000000", 8 * 4 * sizeof(char)));
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_bin(-2147483648), "1111111111111111111111111111111110000000000000000000000000000000", 8 * 8 * sizeof(char)));
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_bin(b), "10000000000000000000000000000000", 8 * 4 * sizeof(char)));
    ud_ut_test(!ud_ut_byte_cmp(ud_ut_to_bin(c), "10000000000000000000000000000000", 8 * 4 * sizeof(char)));

    ud_ut_test(ud_ut_from_bin(int, "00000000000000000000000000000100") == 4);
    ud_ut_test(ud_ut_from_bin(int, "11111111111111111111111111111111") == -1);
    ud_ut_test(ud_ut_from_bin(int, "11111111111111111111111111111110") == -2);
    ud_ut_test(ud_ut_from_bin(int, "01111111111111111111111111111111") == 2147483647);
    ud_ut_test(ud_ut_from_bin(int, "10000000000000000000000000000000") == -2147483648);
    ud_ut_test(ud_ut_from_bin(long, "1111111111111111111111111111111110000000000000000000000000000000") == -2147483648);

    int d = 5;
    int e = 2;
    ud_ut_swap(d, e);
    ud_ut_test(d == 2);
    ud_ut_test(e == 5);

    return (0);
}