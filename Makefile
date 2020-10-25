# ================================== CUSTOMIZED MACROS =================================================================
# Recursive wildcard macro
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# ================================== VARIABLES FROM SHELL COMMANDS =====================================================
GIT_DESCRIPTION_STR=\"$(shell git describe --dirty=-dirty)\"
GIT_COMMIT_HASH_STR=\"$(shell git rev-parse --short HEAD)\"

# ================================== CONSTANTS =========================================================================
# Extensions
SRC_EXT := c
OBJ_EXT := o
DEP_EXT := d
TMP_EXT := tmp
BIN_EXT := elf
# Paths
SRC_DIR := components/
OBJ_DIR := build/obj/
DEP_DIR := build/dep/
BIN_DIR := build/bin/
BIN_NAME := app
# Compiler
CC := gcc
C_FLAGS := -Wall
PRJ_FLAGS := -D_GIT_DESCRIPTION_STR=$(GIT_DESCRIPTION_STR) -D_GIT_COMMIT_HASH_STR=$(GIT_COMMIT_HASH_STR)

# ================================== VARIABLES FROM MACROS =============================================================
BIN_PATH := $(BIN_DIR)$(BIN_NAME).$(BIN_EXT)
SRC_FILES := $(call rwildcard,$(SRC_DIR),*.$(SRC_EXT))
OBJ_FILES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), $(OBJ_DIR)%.$(OBJ_EXT), $(SRC_FILES))
DEP_FILES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), $(DEP_DIR)%.$(DEP_EXT), $(SRC_FILES))

# ================================== TARGETS ===========================================================================
all: $(OBJ_FILES)
	@echo Linking objects to \"$(BIN_PATH)\"
	@mkdir -p $(BIN_DIR)
	@$(CC) $(C_FLAGS) -o $(BIN_PATH) $(OBJ_FILES)
clean:
	@find . -type f -name '*.$(OBJ_EXT)' -exec rm {} +
	@find . -type f -name '*.$(DEP_EXT)' -exec rm {} +
	@find . -type f -name '*.$(BIN_EXT)' -exec rm {} +
run: all
	@echo Running the application
	@echo =========================================================
	@$(BIN_PATH)
$(OBJ_DIR)%.$(OBJ_EXT): $(SRC_DIR)%.$(SRC_EXT) $(DEP_DIR)%.$(DEP_EXT)
	@echo Building \"$@\" from \"$<\"
	@mkdir -p $(dir $@)
	@$(CC) $(C_FLAGS) $(PRJ_FLAGS) -c -o $@ $<
$(DEP_DIR)%.$(DEP_EXT): $(SRC_DIR)%.$(SRC_EXT)
	@echo Creating dependency \"$@\" from \"$<\"
	@mkdir -p $(dir $@)
	@$(CC) -M $< > $(patsubst %.$(DEP_EXT), %.$(TMP_EXT), $@)
	@(echo -n $(OBJ_DIR) && cat $(patsubst %.$(DEP_EXT), %.$(TMP_EXT), $@)) > $@
	@rm -f $(patsubst %.$(DEP_EXT), %.$(TMP_EXT), $@)
include $(DEP_FILES)
