#include "ud_utils.h"

size_t		ud_ut_int_len(int n)
{
    if (n == -2147483648)
		return (11);
	size_t len = 0;
	if (n < 0)
	{
		n *= -1;
		++len;
	}
	for (;n >= 10; ++len) n /= 10;
	return (len + 1);
}