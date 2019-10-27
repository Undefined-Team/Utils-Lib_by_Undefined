#include "ud_utils.h"

void    ud_ut_assert_ctr(char *assertion, ud_bool passed)
{
    if (!passed) ud_ut_error("Assertion failed: (%s), function %s, file %s, line %d.", assertion, __FUNCTION__, __FILE__, __LINE__);
}