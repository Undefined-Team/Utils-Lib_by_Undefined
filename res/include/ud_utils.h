#ifndef UD_UTILS_H
# define UD_UTILS_H

// Lib
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

// Macro
# define ud_ut_args_len(type, ...)      (sizeof((type[]){__VA_ARGS__})/sizeof(type))
# define ud_ut_statica_len(_arr)        ((_arr) ? sizeof(_arr)/sizeof(*(_arr)) : 0)
# define UD_UT_SPACE_NBR		        4
# define UD_UT_COLOR_N                  "\x1b[0m"
# define UD_UT_COLOR_U                  "\x1b[4m"
# define UD_UT_COLOR_B                  "\x1b[1m"
# define UD_UT_COLOR_ERR_1              "\x1b[38;2;209;0;0m"
# define UD_UT_COLOR_ERR_2              "\x1b[38;2;248;51;60m"
# define UD_UT_COLOR_TIME_1             "\x1b[33m"
# define UD_UT_COLOR_TIME_2             "\x1b[93m"
# define UD_UT_COLOR_NBR                5
# define UD_UT_COLOR_1                  "\x1b[38;2;68;175;105m"
# define UD_UT_COLOR_2                  "\x1b[38;2;248;51;60m"
# define UD_UT_COLOR_3                  "\x1b[38;2;43;158;179m"
# define UD_UT_COLOR_4                  "\x1b[38;2;255;127;17m"
# define UD_UT_COLOR_5                  "\x1b[38;2;255;1;251m"

# define ud_ut_free(_x)                 ud_ut_free_ctr((void**)&(_x))
# define ud_ut_prot_malloc(_x)          if (!(_x)) {return NULL;}
# define ud_ut_prot_malloc_void(_x)	    if (!(_x)) {return ;}

# define ud_ut_error(...)               (fprintf(stderr, "%s%s%s[ERROR]%s %s%s: ", UD_UT_COLOR_B, UD_UT_COLOR_U, UD_UT_COLOR_ERR_1, UD_UT_COLOR_N, UD_UT_COLOR_ERR_2, __func__), \
                                        fprintf(stderr, __VA_ARGS__), \
                                        fprintf(stderr, "%s\n", UD_UT_COLOR_N), \
                                        exit(1))

# define ud_ut_error_no_exit(...)       (fprintf(stderr, "%s%s%s[ERROR]%s %s%s: ", UD_UT_COLOR_B, UD_UT_COLOR_U, UD_UT_COLOR_ERR_1, UD_UT_COLOR_N, UD_UT_COLOR_ERR_2, __func__), \
                                        fprintf(stderr, __VA_ARGS__), \
                                        fprintf(stderr, "%s\n", UD_UT_COLOR_N))

# define ud_ut_time(...)                (printf("%s%s%s[TIME]%s %s%lf sec: ", UD_UT_COLOR_B, UD_UT_COLOR_U, UD_UT_COLOR_TIME_1, UD_UT_COLOR_N, UD_UT_COLOR_TIME_2, ud_ut_update_time()), \
                                        printf(__VA_ARGS__), \
                                        printf("%s\n", UD_UT_COLOR_N))

# define ud_ut_assert(_a)               ud_ut_assert_ctr(#_a, _a, __FUNCTION__, __FILE__, __LINE__, UD_UT_ASSERT)
# define ud_ut_test(_a)                 ud_ut_assert_ctr(#_a, _a, __FUNCTION__, __FILE__, __LINE__, UD_UT_TEST)
# define ud_ut_dtest(_a, _form, ...)    ({ int _ret = ud_ut_assert_ctr(#_a, _a, __FUNCTION__, __FILE__, __LINE__, UD_UT_TEST); if (!_ret) {printf("%s>> ", UD_UT_COLOR_2); printf(_form, __VA_ARGS__); printf("%s\n", UD_UT_COLOR_N);} _ret; })

# define ud_ut_to_bin(_a)               ({ typeof(_a) _tmp = _a; char *_byte_ret = ud_ut_to_bin_ctr(&_tmp, sizeof(_a)); _byte_ret; })
# define ud_ut_from_bin(_ctype, _bin)   ({ char *_buf; ud_ut_from_bin_ctr(&_buf, _bin, sizeof(_ctype)); _ctype _val = *(_ctype *)_buf; _val; })

# define ud_ut_swap(a, b)               a ^= b; b ^= a; a ^= b;

# define ud_ut_count                    register size_t

# define ud_ut_array(_type, ...) \
    ({ \
        _type *_new_arr; \
        _type _in_val[] = {__VA_ARGS__}; \
        _type *_in_tmp = _in_val; \
        size_t _len = sizeof(_in_val) / sizeof(_type); \
        _new_arr = ud_ut_malloc(_len * sizeof(_type)); \
        _type *_p_new_arr = _new_arr; \
        for (ud_ut_count _i = 0; _i < _len; ++_i) *_p_new_arr++ = *_in_tmp++; \
        _new_arr; \
    })

# define ud_ut_sarray(_type, ...) \
    ({ \
        _type *_new_arr; \
        _type _in_val[] = {__VA_ARGS__}; \
        _type *_in_tmp = _in_val; \
        size_t _len = sizeof(_in_val) / sizeof(_type); \
        if (_len) \
        { \
            _new_arr = ud_ut_malloc(_len * sizeof(_type)); \
            _type *_p_new_arr = _new_arr; \
            for (ud_ut_count _i = 0; _i < _len; ++_i) *_p_new_arr++ = ud_str_dup(*_in_tmp++); \
        } \
        else _new_arr = NULL; \
        _new_arr; \
    })

# define ud_ut_sarray_null(_type, ...) \
    ({ \
        _type *_new_arr; \
        _type _in_val[] = {__VA_ARGS__}; \
        _type *_in_tmp = _in_val; \
        size_t _len = sizeof(_in_val) / sizeof(_type); \
        if (_len) \
        { \
            _new_arr = ud_ut_malloc((_len + 1) * sizeof(_type)); \
            type *_p_new_arr = _new_arr; \
            for (ud_ut_count _i = 0; _i < _len; ++_i, ++_p_new_arr, ++_in_tmp) *_p_new_arr = ud_str_dup(*_in_tmp); \
            *_p_new_arr = NULL; \
        } \
        else _new_arr = NULL; \
        _new_arr; \
    })

// Structures
typedef enum                        {false,true} ud_bool;
typedef enum                        {UD_UT_ASSERT, UD_UT_TEST, UD_UT_TIME} ud_ut_test_type;

// Prototypes
void	                            ud_ut_free_ctr(void **ap);
double                              ud_ut_update_time(void);
void                                *ud_ut_malloc(size_t len);
int                                 ud_ut_assert_ctr(char *assertion, ud_bool passed, const char function[], const char file[], int line, ud_ut_test_type test_type);
char                                *ud_ut_to_bin_ctr(void *val, size_t nb_bytes);
void                                *ud_ut_from_bin_ctr(char **buf, char *bin, size_t nb_bytes);

extern char                         *ud_ut_color_t[];

#endif
