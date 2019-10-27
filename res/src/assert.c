#include "ud_utils.h"

void    ud_ut_assert_ctr(char *assertion, ud_bool passed, const char function[], const char file[], int line)
{
    if (!passed) ud_ut_error("Assertion failed: (%s), function %s, file %s, line %d.", assertion, function, file, line);
}