# include <ud_utils.h>
# include <stdio.h>

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