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
R                 =     \033[0;31m
G                 =     \033[32;7m
B                 =     \033[0;34m
N                 =     \33[0m
# Colors

all: $(NAME)

$(NAME): $(BIN)
	@ar rc ${LIBNAME} $^
	@echo "\n${N}Library ${LIBNAME} compiled."
	@ranlib ${LIBNAME}
	@echo "Library ${LIBNAME} indexed."

$(BIN_PATH)%.o: $(SRC_PATH)%.c
	@mkdir -p $(BIN_PATH) || true
	$(COMPILE) $^ -o $@ $(DEPNAME) -c

clean:
	@rm -f $(BIN)

fclean: clean
	@rm -f lib$(NAME).a

re: fclean all
