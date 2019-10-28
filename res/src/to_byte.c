#include "ud_utils.h"

char    *ud_ut_to_byte_ctr(void *val, size_t nb_bytes)
{
    if (!val || !nb_bytes) return NULL;
    if (*(char *)val == 0)
    {
        char *ret = malloc(nb_bytes * 8 * nb_bytes);
        char *p_ret = ret;
        for (ud_ut_count i = 0; i < nb_bytes * 8; ++i, ++p_ret)
            *p_ret = '0';
        *p_ret = 0;
        return ret;
    }

    int     n = 1;
    int     endian = -1;                // big endian :     1 == 00000000 00000000 00000000 00000001
    if (*(char *)&n == 1) endian = 1;   // little endian :  1 == 00000001 00000000 00000000 00000000

    size_t  len = nb_bytes * 8;
    char    *byte = malloc((len + 1) * sizeof(char));
    char    *p_byte = byte;
    char    *p_val = (endian == 1) ? (char *)val : (char *)(val + nb_bytes - 1);
    int     threshold = (endian == 1) ? 8 : -1;
    
    byte[len] = 0;
    if (endian == 1) byte = &byte[len - 1];
    for (ud_ut_count i = 0; i < nb_bytes; ++i, p_val += endian)
    {
        ud_ut_count j = (endian == 1) ? 0 : 7;
        for (; (int)j != threshold; j += endian, byte -= endian)
            *byte = ((*p_val >> j) & 1) ? '1' : '0';
    }
    return p_byte;
}