#include <ud_utils.h>

double    ud_ut_update_time(void)
{
    static struct timeval  ud_ut_time_before;
    static struct timeval  ud_ut_time_after;
    static bool            first_coming = true;

    if (first_coming)
    {
        gettimeofday (&ud_ut_time_before, NULL);
        first_coming = false;
        return 0;
    }
    gettimeofday (&ud_ut_time_after, NULL);
    long int time = ((ud_ut_time_after.tv_sec - ud_ut_time_before.tv_sec) * 1000000 + ud_ut_time_after.tv_usec) - ud_ut_time_before.tv_usec;
    double realtime = (double)time / 1000000;
    gettimeofday (&ud_ut_time_before, NULL);
    return realtime;
}