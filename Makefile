FLAGS             =     -g -Wall -Wextra -Werror -O3
CC                =     gcc

SRC_PATH          =     ./res/src/
BIN_PATH          =     ./res/bin/
INCLUDE_PATH      =     ./res/include/

BLACKLIST         =

SRC_BLACKLIST     =     $(addprefix $(SRC_PATH), $(BLACKLIST))

INCLUDE           =     -I$(INCLUDE_PATH)
SRCS              =     $(wildcard $(SRC_PATH)*.c)
SRC               =     $(filter-out $(SRC_BLACKLIST), $(SRCS))
BINS              =     $(SRC:.c=.o)
BIN               =     $(addprefix $(BIN_PATH), $(notdir $(BINS)))

COMPILE           =     $(CC) $(FLAGS) $(INCLUDE)

.PHONY            =     all clean fclean re static

# Colors
R                 =     \033[0;31m
G                 =     \33[32;7m
B                 =     \033[0;34m
N                 =     \033[0m
# Colors

all: $(LIBNAME)

$(LIBNAME): $(BIN)
	@ar rc ${LIBNAME} $^
	@echo "\nLibrary ${LIBNAME} compiled."
	@ranlib ${LIBNAME}
	@echo "Library ${LIBNAME} indexed."

$(BIN_PATH)%.o: $(SRC_PATH)%.c
	@mkdir -p $(BIN_PATH) || true
	$(COMPILE) $^ -o $@ $(DEPNAME) -c

clean:
	@rm -f $(BIN)

fclean: clean
	@rm -f ${wildcard *.a}

re: fclean all

static: extract
	@$(eval LIB_OBJ=$(shell echo *.o))
	@ar rc ${LIBNAME} ${LIB_OBJ}
	@echo "\nLibrary ${LIBNAME} compiled."
	@ranlib ${LIBNAME}
	@echo "Library ${LIBNAME} indexed."
	@rm *.o

extract:
	@for dep in $(DEPNAME); do \
		ar x $${dep}; \
	done