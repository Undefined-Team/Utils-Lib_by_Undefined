#include "ud_utils.h"

void    *ud_ut_from_bin_ctr(char **buf, char *bin, size_t nb_bytes)
{
    if (!bin) return NULL;
    int     n = 1;
    int     endian = -1;                // big endian :     1 == 00000000 00000000 00000000 00000001
    if (*(char *)&n == 1) endian = 1;   // little endian :  1 == 00000001 00000000 00000000 00000000

    char    ret[nb_bytes];
    int     threshold = (endian == 1) ? 8 : -1;
    int     j_begin = (endian == 1) ? 0 : 7;
    char    *p_ret = (endian == -1) ? &ret[nb_bytes] : ret;
    char    *p_bin = &bin[nb_bytes * 8 - 1];

    for (ud_ut_count i = 0; i < nb_bytes; ++i, p_ret += endian)
    {
        *p_ret = 0;
        int j = j_begin;
        for (; j != threshold; j += endian, --p_bin)
            if (*p_bin == '1') *p_ret |= (1 << j);
    }
    *buf = ret;
    return *buf;
}