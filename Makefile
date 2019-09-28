NAME              =     ud_utils
LIB_NAME          =     libud
FLAGS             =     -g -Wall -Wextra -Werror -O3
CC                =     gcc

SRC_PATH          =     ./res/src/
BIN_PATH          =     ./res/bin/
INCLUDE_PATH      =     ./lib/include/
LIB_PATH          =     ./lib/bin/

BLACKLIST         =

SRC_BLACKLIST     =     $(addprefix $(SRC_PATH), $(BLACKLIST))

INCLUDE           =     -I$(INCLUDE_PATH)
SRCS              =     $(wildcard $(SRC_PATH)*.c)
SRC               =     $(filter-out $(SRC_BLACKLIST), $(SRCS))
BINS              =     $(SRC:.c=.o)
BIN               =     $(addprefix $(BIN_PATH), $(notdir $(BINS)))
LIB               =     $(wildcard $(LIB_PATH)*.a)
LDFLAGS           =     -L$(LIB_PATH) $(addprefix -l, $(LIB))

COUNT             =     $(words $(SRC))
STEP              =     $(shell expr 100 / $(COUNT))
LENGTH            =     $(shell expr $(COUNT) \* $(STEP))
n                 =     0
BAR               =     "${G} \c"

COMPILE           =     $(CC) $(FLAGS) $(INCLUDE)

.PHONY            =     all clean fclean re bar

# Colors
R                 =     \033[0;31m
G                 =     \033[32;7m
B                 =     \033[0;34m
N                 =     \33[0m
# Colors

all: bar $(NAME)

bar:
	@n=${LENGTH}; \
		while [ $${n} -gt 0 ] ; do \
			echo "${R}█\c"; \
			n=`expr $$n - 1` ; \
		done; \
	true
	@echo "\033[$(shell expr $(LENGTH) + 1)D\c"

$(NAME): $(BIN)
	@ar rc lib$(NAME).a $^
	@echo "\n\n${N}Library lib${NAME}.a compiled."
	@ranlib lib$(NAME).a
	@echo "Library lib${NAME}.a indexed."

$(BIN_PATH)%.o: $(SRC_PATH)%.c
	@mkdir -p $(BIN_PATH) || true
	@if [ -d $(LIB_PATH) ]; then \
		$(COMPILE) $^ -o $@ $(LDFLAGS) -c; \
	else \
		$(COMPILE) $^ -o $@ -c; \
	fi
	@n=$(STEP); \
	while [ $${n} -gt 0 ] ; do \
		echo "${G} \c" ; \
		n=`expr $$n - 1`; \
		done; \
	true

clean:
	@rm -f $(BIN)

fclean: clean
	@rm -f lib$(NAME).a

re: fclean all

install: all
#	@mkdir -p ${HOME}/${LIB_NAME}
#	@mkdir -p ${HOME}/${LIB_NAME}/lib || true
#	@mkdir -p ${HOME}/${LIB_NAME}/include || true
#ifndef ($(LD_LIBRARY_PATH))
#	@echo "try export LD_LIBRARY_PATH=\$$LD_LIBRARY_PATH:\$$HOME/${LIB_NAME}/lib/"
#endif
#ifndef ($(C_INCLUDE_PATH))
#	@echo "try export C_INCLUDE_PATH=\$$C_INCLUDE_PATH:\$$HOME/${LIB_NAME}/include/"
#endif
	@cp lib${NAME}.a /usr/lib
	@cp lib${NAME}.a /usr/local/lib
	@cp ${INCLUDE_PATH}${NAME}.h /usr/include
	@cp ${INCLUDE_PATH}${NAME}.h /usr/local/include

uninstall:
#	@rm ${HOME}/lib/lib${NAME}.a \
		${HOME}/include/${INCLUDE_NAME}.h
	@rm /usr/local/lib/lib${NAME}.a \
		/usr/lib/lib${NAME}.a \
		/usr/local/include/${INCLUDE_PATH}${NAME}.h \
		/usr/include/${INCLUDE_PATH}${NAME}.h
