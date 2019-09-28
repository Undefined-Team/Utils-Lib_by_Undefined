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

.PHONY            =     all clean fclean re

# Colors
G                 =     \033[1;32m
N                 =     \33[0m
# Colors

all: $(NAME)

$(NAME): $(BIN)
	@ar rc ${LIBNAME} $^
	@echo "	$(G)Success: Library ${LIBNAME} compiled.$(N)"
	@ranlib ${LIBNAME}
	@echo "	$(G)Success: Library ${LIBNAME} indexed.$(N)"

$(BIN_PATH)%.o: $(SRC_PATH)%.c
	@mkdir -p $(BIN_PATH) || true
	@echo -n "\t$(G)Success: "
	$(COMPILE) $^ -o $@ $(DEPNAME) -c
	@echo -n "$(N)"

clean:
	@rm -f $(BIN)

fclean: clean
	@rm -f libud*.a

re: fclean all
