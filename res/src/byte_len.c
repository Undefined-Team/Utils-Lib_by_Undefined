#include "ud_utils.h"

size_t ud_ut_byte_len(char *bytes)
{
    size_t len = 0;
    while (*bytes++) ++len;
    return len;
}