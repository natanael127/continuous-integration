# ================================== MACROS ============================================================================
# Recursive wildcard macro
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# ================================== CONSTANTS =========================================================================
OBJ_FOLDER := obj/
COMP_FOLDER := components/
BIN_FOLDER := bin/
CC := gcc
FLAGS := -Wall
OUTPUT := $(BIN_FOLDER)output.bin

# ================================== VARIABLES FROM MACROS =============================================================
SRC_FILES := $(call rwildcard,$(COMP_FOLDER),*.c)
OBJ_NAMES := $(patsubst $(COMP_FOLDER)%.c, %.o, $(SRC_FILES))
OBJ_FILES := $(addprefix $(OBJ_FOLDER), $(OBJ_NAMES))

# ================================== TARGETS ===========================================================================
all:$(OBJ_FILES)
	@echo Linking to \"$(OUTPUT)\"
	@mkdir -p $(BIN_FOLDER)
	@$(CC) $(FLAGS) -o $(OUTPUT) $(OBJ_FILES)
clean:
	@find . -type f -name '*.o' -exec rm {} +
	@find . -type f -name '*.bin' -exec rm {} +
run:all
	@$(OUTPUT)
$(OBJ_FOLDER)%.o:$(COMP_FOLDER)%.c
	@echo Building \"$@\" from \"$<\"
	@mkdir -p $(dir $@)
	@$(CC) $(FLAGS) -c -o $@ $<
