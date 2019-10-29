#include "ud_utils.h"

void    *ud_ut_from_bin_ctr(char **buf, char *bin, size_t nb_bytes, ud_bool is_array)
{
    if (!bin) return NULL;
    int     n = 1;
    int     endian = -1;                // big endian :     1 == 00000000 00000000 00000000 00000001
    if (*(char *)&n == 1 && !is_array) endian = 1;   // little endian :  1 == 00000001 00000000 00000000 00000000

    char    ret[nb_bytes];
    int     threshold = (endian == 1) ? 8 : -1;
    int     j_begin = (endian == 1) ? 0 : 7;
    char    *p_ret = (endian == -1 && !is_array) ? &ret[nb_bytes] : ret;
    char    *p_bin = (is_array) ? bin : &bin[nb_bytes * 8 - 1];
    int     ret_incr = (is_array) ? 1 : endian;
    int     bin_incr = (is_array) ? 1 : -1;

    for (ud_ut_count i = 0; i < nb_bytes; ++i, p_ret += ret_incr)
    {
        *p_ret = 0;
        int j = j_begin;
        for (; j != threshold; j += endian, p_bin += bin_incr)
            if (*p_bin == '1') *p_ret |= (1 << j);
    }
    *buf = ret;
    return *buf;
}