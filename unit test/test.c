# include <ud_utils.h>
# include <stdio.h>

int main(void)
{
    int test[] = {};
    printf("%zd\n", UD_UT_STATICA_LEN(test));
    int test2[] = {0};
    printf("%zd\n", UD_UT_STATICA_LEN(test2));
    return (0);
}