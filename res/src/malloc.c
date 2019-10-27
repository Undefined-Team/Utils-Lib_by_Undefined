#include "ud_utils.h"

void    *ud_ut_malloc(size_t len)
{
    if (len > 0)
    {
            void *tmp = malloc(len);
            if (tmp)
                    return tmp;
            ud_ut_error("Too much memory allocated (%zu bytes).", len);
    }
    return NULL;
}