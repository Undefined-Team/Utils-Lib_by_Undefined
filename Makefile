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
G                 =     \33[1;32m
N                 =     \033[0m
# Colors

all: libud_$(LIBNAME).a
	@echo > /dev/null

libud_$(LIBNAME).a: $(BIN)
	@ar rc libud_${LIBNAME}.a ${BIN}
	@echo "\t$(G)Success: Dynamic library [ libud_${LIBNAME}.a ] compiled.$(N)"
	@ranlib libud_${LIBNAME}.a
	@echo "\t$(G)Success: Dynamic library [ libud_${LIBNAME}.a ] indexed.$(N)"

$(BIN_PATH)$(LIBNAME)_%.o: $(SRC_PATH)%.c
	@mkdir -p $(BIN_PATH) || true
	@echo -n "\t$(G)Success: "
	$(COMPILE) $^ $(DEPNAME) -o $@ -c
	@echo -n "$(N)"

clean:
	@rm -f $(BIN_PATH)/*.o

fclean: clean
	@rm -f ${wildcard *.a}

re: fclean all

static: libud_${LIBNAME}.a extract
	@$(eval LIB_OBJ=$(shell echo *.o))
	@ar rc libud_${LIBNAME}.a ${BIN} ${LIB_OBJ}
	@echo "\t$(G)Success: Static library [ libud_${LIBNAME}.a ] compiled.$(N)"
	@ranlib libud_${LIBNAME}.a
	@echo "\t$(G)Success: Static library [ libud_${LIBNAME}.a ] indexed.$(N)"
	@rm *.o

extract:
	@for dep in $(ARNAME); do \
		ar x $${dep}; \
	done