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
BIN               =     $(addprefix $(BIN_PATH), $(addprefix $(LIBNAME)_, $(notdir $(BINS))))

COMPILE           =     $(CC) $(FLAGS) $(INCLUDE)

.PHONY            =     all clean fclean re static

# Colors
R                 =     \033[0;31m
G                 =     \33[32;7m
B                 =     \033[0;34m
N                 =     \033[0m
# Colors

all: libud_$(LIBNAME).a

libud_$(LIBNAME).a: $(BIN)
	@ar rc libud_${LIBNAME}.a ${BIN}
	@echo "\nLibrary libud_${LIBNAME}.a compiled."
	@ranlib libud_${LIBNAME}.a
	@echo "Library libud_${LIBNAME}.a indexed."

$(BIN_PATH)$(LIBNAME)_%.o: $(SRC_PATH)%.c
	@mkdir -p $(BIN_PATH) || true
	$(COMPILE) $^ -o $@ $(DEPNAME) -c

clean:
	@rm -f $(BIN_PATH)/*.o

fclean: clean
	@rm -f ${wildcard *.a}

re: fclean all

static: libud_${LIBNAME}.a extract
	@$(eval LIB_OBJ=$(shell echo *.o))
	@ar rc libud_${LIBNAME}.a ${BIN} ${LIB_OBJ}
	@echo "\nStatic library libud_${LIBNAME}.a compiled."
	@ranlib libud_${LIBNAME}.a
	@echo "Static library libud_${LIBNAME}.a indexed."
	@rm *.o

extract:
	@for dep in $(DEPNAME); do \
		ar x $${dep}; \
	done