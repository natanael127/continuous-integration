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
SRC_FOLDER := components/
OBJ_FOLDER := build/obj/
DEP_FOLDER := build/dep/
BIN_FOLDER := build/bin/
BIN_NAME := app
# Compiler
CC := gcc
FLAGS := -Wall

# ================================== VARIABLES FROM MACROS =============================================================
BIN_PATH := $(BIN_FOLDER)$(BIN_NAME).$(BIN_EXT)
SRC_FILES := $(call rwildcard,$(SRC_FOLDER),*.$(SRC_EXT))
OBJ_NAMES := $(patsubst $(SRC_FOLDER)%.$(SRC_EXT), %.$(OBJ_EXT), $(SRC_FILES))
OBJ_FILES := $(addprefix $(OBJ_FOLDER), $(OBJ_NAMES))

# ================================== TARGETS ===========================================================================
all: $(OBJ_FILES)
	@echo Linking objects to \"$(BIN_PATH)\"
	@mkdir -p $(BIN_FOLDER)
	@$(CC) $(FLAGS) -o $(BIN_PATH) $(OBJ_FILES)
clean:
	@find . -type f -name '*.$(OBJ_EXT)' -exec rm {} +
	@find . -type f -name '*.$(DEP_EXT)' -exec rm {} +
	@find . -type f -name '*.$(BIN_EXT)' -exec rm {} +
run: all
	@echo Running the application
	@echo =========================================================
	@$(BIN_PATH)
$(OBJ_FOLDER)%.$(OBJ_EXT): $(SRC_FOLDER)%.$(SRC_EXT)
	@echo Building \"$@\" from \"$<\"
	@mkdir -p $(dir $@)
	@$(CC) $(FLAGS) -c -o $@ $<
