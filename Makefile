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
	@$(CC) $(FLAGS) -o $(OUTPUT) $(OBJ_FILES)
clean:
	@mkdir -p $(OBJ_FOLDER)
	@find $(OBJ_FOLDER) -type f -name '*.o' -exec rm {} +
	@find $(BIN_FOLDER) -type f -name '*.bin' -exec rm {} +
run:all
	@$(OUTPUT)
%.o:
	@mkdir -p $(dir $@)
	@echo Building $(addprefix $(COMP_FOLDER), $(patsubst $(OBJ_FOLDER)%.o, %.c, $@))
	@$(CC) $(FLAGS) -c -o $@ $(addprefix $(COMP_FOLDER), $(patsubst $(OBJ_FOLDER)%.o, %.c, $@))
