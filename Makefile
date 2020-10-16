# ================================== CUSTOMIZED MACROS =================================================================
# Recursive wildcard macro
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# ================================== CONSTANTS =========================================================================
# Extensions
SRC_EXT := c
OBJ_EXT := o
DEP_EXT := d
BIN_EXT := elf
# Paths
SRC_DIR := components/
OBJ_DIR := build/obj/
DEP_DIR := build/dep/
BIN_DIR := build/bin/
BIN_NAME := app
# Compiler
CC := gcc
CFLAGS := -Wall

# ================================== VARIABLES FROM MACROS =============================================================
BIN_PATH := $(BIN_DIR)$(BIN_NAME).$(BIN_EXT)
SRC_FILES := $(call rwildcard,$(SRC_DIR),*.$(SRC_EXT))
OBJ_NAMES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), %.$(OBJ_EXT), $(SRC_FILES))
OBJ_FILES := $(addprefix $(OBJ_DIR), $(OBJ_NAMES))

# ================================== TARGETS ===========================================================================
all: $(OBJ_FILES)
	@echo Linking objects to \"$(BIN_PATH)\"
	@mkdir -p $(BIN_DIR)
	@$(CC) $(CFLAGS) -o $(BIN_PATH) $(OBJ_FILES)
clean:
	@find . -type f -name '*.$(OBJ_EXT)' -exec rm {} +
	@find . -type f -name '*.$(DEP_EXT)' -exec rm {} +
	@find . -type f -name '*.$(BIN_EXT)' -exec rm {} +
run: all
	@echo Running the application
	@echo =========================================================
	@$(BIN_PATH)
$(OBJ_DIR)%.$(OBJ_EXT): $(SRC_DIR)%.$(SRC_EXT)
	@echo Building \"$@\" from \"$<\"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c -o $@ $<
