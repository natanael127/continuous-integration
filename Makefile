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
LST_EXT := json
ANL_EXT := txt
BIN_EXT := elf
# Paths
BUILD_DIR := build/
SRC_DIR := components/
OBJ_DIR := $(BUILD_DIR)obj/
DEP_DIR := $(BUILD_DIR)dep/
BIN_DIR := $(BUILD_DIR)bin/
ANL_DIR := $(BUILD_DIR)analysis/
BIN_NAME := app
# Compiler
CC := gcc
C_FLAGS := -Wall
PRJ_FLAGS := -D_GIT_DESCRIPTION_STR=$(GIT_DESCRIPTION_STR) -D_GIT_COMMIT_HASH_STR=$(GIT_COMMIT_HASH_STR)
TEST_FLAGS := -D_TEST_MODE
# Static analysis
LST_NAME := project
ANL_NAME := analysis


# ================================== VARIABLES FROM MACROS =============================================================
BIN_PATH := $(BIN_DIR)$(BIN_NAME).$(BIN_EXT)
SRC_FILES := $(call rwildcard,$(SRC_DIR),*.$(SRC_EXT))
OBJ_FILES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), $(OBJ_DIR)%.$(OBJ_EXT), $(SRC_FILES))
DEP_FILES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), $(DEP_DIR)%.$(DEP_EXT), $(SRC_FILES))
LST_FILE := $(ANL_DIR)$(LST_NAME).$(LST_EXT)
ANL_FILE := $(ANL_DIR)$(ANL_NAME).$(ANL_EXT)

# ================================== TARGETS ===========================================================================
all: $(OBJ_FILES)
	@echo Linking objects to \"$(BIN_PATH)\"
	@mkdir -p $(BIN_DIR)
	@$(CC) $(C_FLAGS) -o $(BIN_PATH) $(OBJ_FILES)
clean:
	@find $(BUILD_DIR) -type f -name '*.$(OBJ_EXT)' -exec rm {} +
	@find $(BUILD_DIR) -type f -name '*.$(DEP_EXT)' -exec rm {} +
	@find $(BUILD_DIR) -type f -name '*.$(LST_EXT)' -exec rm {} +
	@find $(BUILD_DIR) -type f -name '*.$(ANL_EXT)' -exec rm {} +
	@find $(BUILD_DIR) -type f -name '*.$(BIN_EXT)' -exec rm {} +
run: all
	@echo Running the application
	@echo =========================================================
	@$(BIN_PATH)
analysis: clean analysis_list
	@echo Static analysis
	@echo =========================================================
	@cppcheck --enable=all --project=$(LST_FILE) --output-file=$(ANL_FILE)
	@cat $(ANL_FILE)
analysis_list:
	@mkdir -p $(ANL_DIR)
	@bear -o $(LST_FILE) make -s
test: clean test_setup run
test_setup:
	@$(eval PRJ_FLAGS += $(TEST_FLAGS))
$(OBJ_DIR)%.$(OBJ_EXT): $(SRC_DIR)%.$(SRC_EXT) $(DEP_DIR)%.$(DEP_EXT)
	@echo Building \"$@\" from \"$<\"
	@mkdir -p $(dir $@)
	@$(CC) $(C_FLAGS) $(PRJ_FLAGS) -c -o $@ $<
$(DEP_DIR)%.$(DEP_EXT): $(SRC_DIR)%.$(SRC_EXT)
	@mkdir -p $(dir $@)
	@$(CC) -MM $< > $(patsubst %.$(DEP_EXT), %.$(TMP_EXT), $@)
	@(echo -n $(OBJ_DIR) && cat $(patsubst %.$(DEP_EXT), %.$(TMP_EXT), $@)) > $@
	@rm -f $(patsubst %.$(DEP_EXT), %.$(TMP_EXT), $@)
include $(DEP_FILES)
