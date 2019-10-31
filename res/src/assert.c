#include "ud_utils.h"

void __attribute__ ((constructor))  ud_tests_ctor() { ud_ut_time("Starting tests..."); }
void __attribute__ ((destructor))   ud_tests_dtor() { ud_ut_assert_ctr(0, 0, NULL, NULL, 0, UD_UT_TIME); }

int ud_ut_assert_ctr(char *assertion, ud_bool passed, const char function[], const char file[], int line, ud_ut_test_type test_type)
{
    static int nb_error = 0;
    static int nb_test = 0;
    ++nb_test;
    if (test_type == UD_UT_TEST)
    {
        if (passed)
            printf("%s✓%s", UD_UT_COLOR_1, UD_UT_COLOR_N);
        else if (++nb_error)
        {
            printf("\n%s✗ [%s] on line %d (function [%s] in file %s)%s\n", UD_UT_COLOR_2, assertion, line, function, file, UD_UT_COLOR_N);
            return 0;
        }
    }
    else if (test_type == UD_UT_ASSERT && !passed && ++nb_error) ud_ut_error("Assertion failed: (%s), function %s, file %s, line %d.", assertion, function, file, line);
    else if (test_type == UD_UT_TIME && nb_test--) 
    {
        printf("\n");
        ud_ut_time("%d/%d tests passed", nb_test - nb_error, nb_test);
    }
    return 1;
}