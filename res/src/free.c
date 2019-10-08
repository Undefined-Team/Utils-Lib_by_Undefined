#include "ud_utils.h"

void	ud_ut_free_ctr(void **ap)
{
	if (ap)
	{
		free(*ap);
		*ap = NULL;
	}
}