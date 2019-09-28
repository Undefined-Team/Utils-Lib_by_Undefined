#ifndef UD_UTILS_H
# define UD_UTILS_H

// Lib
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

// Macro
# define UD_UT_PRINT_SPACE		    "    "
# define UD_UT_COLOR_N              "\x1b[0m"
# define UD_UT_COLOR_U              "\x1b[4m"
# define UD_UT_COLOR_B              "\x1b[1m"
# define UD_UT_COLOR_ERR_1          "\x1b[38;2;209;0;0m"
# define UD_UT_COLOR_ERR_2          "\x1b[38;2;248;51;60m"
# define UD_UT_COLOR_TIME_1         "\x1b[33m"
# define UD_UT_COLOR_TIME_2         "\x1b[93m"
# define UD_UT_COLOR_NBR            5
# define UD_UT_COLOR_1              "\x1b[38;2;68;175;105m"
# define UD_UT_COLOR_2              "\x1b[38;2;248;51;60m"
# define UD_UT_COLOR_3              "\x1b[38;2;43;158;179m"
# define UD_UT_COLOR_4              "\x1b[38;2;255;127;17m"
# define UD_UT_COLOR_5              "\x1b[38;2;255;1;251m"

# define ud_ut_free(x)              ud_ut_free_ctr((void**)&(x))
# define UD_UT_PROT_MALLOC(x)       if (!(x)) {return NULL;}
# define UD_UT_PROT_ARR_TYPE(x, y)  if (x != y) {return NULL;}

# define ud_ut_error(...)           (fprintf(stderr, "%s%s%s[ERROR]%s %s%s: ", UD_UT_COLOR_B, UD_UT_COLOR_U, UD_UT_COLOR_ERR_1, UD_UT_COLOR_N, UD_UT_COLOR_ERR_2, __func__), \
                                    fprintf(stderr, __VA_ARGS__), \
                                    fprintf(stderr, "%s\n", UD_UT_COLOR_N), \
                                    exit(1))

# define ud_ut_error_no_exit(...)   (fprintf(stderr, "%s%s%s[ERROR]%s %s%s: ", UD_UT_COLOR_B, UD_UT_COLOR_U, UD_UT_COLOR_ERR_1, UD_UT_COLOR_N, UD_UT_COLOR_ERR_2, __func__), \
                                    fprintf(stderr, __VA_ARGS__), \
                                    fprintf(stderr, "%s\n", UD_UT_COLOR_N))

# define ud_ut_time(...)            (printf("%s%s%s[TIME]%s %s%lf sec: ", UD_UT_COLOR_B, UD_UT_COLOR_U, UD_UT_COLOR_TIME_1, UD_UT_COLOR_N, UD_UT_COLOR_TIME_2, ud_ut_update_time()), \
                                    printf(__VA_ARGS__), \
                                    printf("%s\n", UD_UT_COLOR_N))

# define ud_ut_count                register size_t

// Structures
typedef enum                        {false,true} bool;

// Prototypes
void	                            ud_ut_free_ctr(void **ap);
double                              ud_ut_update_time(void);
void                                *ud_ut_malloc(size_t len);

extern char                         *ud_ut_color_t[];

#endif