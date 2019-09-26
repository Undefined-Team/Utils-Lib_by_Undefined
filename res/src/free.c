#include "ud_ut.h"

void	ud_ut_free_ctr(void **ap)
{
	if (ap)
	{
		free(*ap);
		*ap = NULL;
	}
}