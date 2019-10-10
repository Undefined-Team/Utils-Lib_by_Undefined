#include "ud_utils.h"

size_t      ud_ut_ptr_len(void **ptr)
{
    size_t len = 0;
    while (*ptr++) ++len;
    return len;
}