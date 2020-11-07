# ================================== CUSTOMIZED MACROS =================================================================
# Recursive wildcard macro
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# ================================== VARIABLES FROM SHELL COMMANDS =====================================================
GIT_DESCRIPTION_STR=$(shell git describe --dirty=-dirty)
GIT_COMMIT_HASH_STR=$(shell git rev-parse --short HEAD)
GIT_TAGS=$(shell git tag)

# ================================== CONSTANTS =========================================================================
# Extensions
SRC_EXT := c
HDR_EXT := h
OBJ_EXT := o
DEP_EXT := d
TMP_EXT := tmp
LST_EXT := json
ANL_EXT := txt
BIN_EXT := elf
# Paths
BUILD_DIR := build/
RLEAS_DIR := released/
SRC_DIR := components/
OBJ_DIR := $(BUILD_DIR)obj/
DEP_DIR := $(BUILD_DIR)dep/
BIN_DIR := $(BUILD_DIR)bin/
ANL_DIR := $(BUILD_DIR)analysis/
CPX_DIR := $(ANL_DIR)complexity/
TAG_DIR := $(RLEAS_DIR)tagged/
OTR_DIR := $(RLEAS_DIR)other/
BIN_NAME := app
# Compiler
CC := gcc
C_FLAGS := -Wall
PRJ_FLAGS := -D_GIT_DESCRIPTION_STR=\"$(GIT_DESCRIPTION_STR)\" -D_GIT_COMMIT_HASH_STR=\"$(GIT_COMMIT_HASH_STR)\"
TEST_FLAGS := -D_TEST_MODE
# Static analysis
LST_NAME := project
STC_NAME := static
CPX_NAME := complexity
COMPLEXITY_GLOBAL_THRESHOLD := 0
# Git
GIT_MAIN_BRANCH := automatic-release-tags

# ================================== VARIABLES FROM MACROS =============================================================
BIN_FILE := $(BIN_DIR)$(BIN_NAME).$(BIN_EXT)
SRC_FILES := $(call rwildcard,$(SRC_DIR),*.$(SRC_EXT))
HDR_FILES := $(call rwildcard,$(SRC_DIR),*.$(HDR_EXT))
OBJ_FILES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), $(OBJ_DIR)%.$(OBJ_EXT), $(SRC_FILES))
DEP_FILES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), $(DEP_DIR)%.$(DEP_EXT), $(SRC_FILES))
TAG_FILES := $(patsubst %, $(TAG_DIR)%.$(BIN_EXT), $(GIT_TAGS))
LST_FILE := $(ANL_DIR)$(LST_NAME).$(LST_EXT)
STC_FILE := $(ANL_DIR)$(STC_NAME).$(ANL_EXT)
CPX_FILE := $(ANL_DIR)$(CPX_NAME).$(ANL_EXT)

# ================================== TARGETS ===========================================================================
all: $(OBJ_FILES)
	@echo Linking objects to \"$(BIN_FILE)\"
	@mkdir -p $(BIN_DIR)
	@$(CC) $(C_FLAGS) -o $(BIN_FILE) $(OBJ_FILES)
clean:
	@rm -rf $(BUILD_DIR)
run: all
	@echo Running the application
	@echo =========================================================
	@$(BIN_FILE)
format:
	@clang-format --style=file -i $(SRC_FILES) $(HDR_FILES)
descripted: all
	@mkdir -p $(OTR_DIR)
	@cp "$(BIN_FILE)" "$(OTR_DIR)$(GIT_DESCRIPTION_STR).$(BIN_EXT)"
releases: save_work $(TAG_FILES)
	@git checkout $(GIT_COMMIT_HASH_STR)
	@echo Releases successfully generated!
save_work:
	@git stash save -u "Saved from make process"
analysis:
	@mkdir -p $(ANL_DIR)
	@make --always-make --dry-run | grep -wE 'gcc|g++' | grep -w '\-c' | jq -nR '[inputs|{directory:".", command:., file: match(" [^ ]+$$").string[1:]}]' > $(LST_FILE)
	@cppcheck --quiet --enable=all --project=$(LST_FILE) --output-file=$(STC_FILE)
	@complexity --histogram --score --thresh=$(COMPLEXITY_GLOBAL_THRESHOLD) $(SRC_FILES) > $(CPX_FILE)
	@cat $(STC_FILE)
	@cat $(CPX_FILE)
test: clean test_setup run
test_setup:
	@$(eval PRJ_FLAGS += $(TEST_FLAGS))
$(TAG_DIR)%.$(BIN_EXT):
	@mkdir -p $(TAG_DIR)
	@$(eval THE_TAG := $(patsubst $(TAG_DIR)%.$(BIN_EXT),%, $@))
	@git checkout $(THE_TAG)
	@git checkout $(GIT_MAIN_BRANCH) -- Makefile
	@make -s
	@cp "$(BIN_FILE)" "$(TAG_DIR)$(THE_TAG).$(BIN_EXT)"
	@echo Should release $(THE_TAG) here
$(OBJ_DIR)%.$(OBJ_EXT): $(SRC_DIR)%.$(SRC_EXT) $(DEP_DIR)%.$(DEP_EXT)
	@echo Building \"$@\" from \"$<\"
	@$(eval CPX_INDIVIDUAL_FILE := $(patsubst $(OBJ_DIR)%.$(OBJ_EXT),$(CPX_DIR)%.$(ANL_EXT), $@))
	@mkdir -p $(dir $(CPX_INDIVIDUAL_FILE))
	@mkdir -p $(dir $@)
	@$(CC) $(C_FLAGS) $(PRJ_FLAGS) -c -o $@ $<
	@complexity --histogram --score --trace=$(CPX_INDIVIDUAL_FILE) --thresh=$(COMPLEXITY_GLOBAL_THRESHOLD) $< >> $(CPX_INDIVIDUAL_FILE)
$(DEP_DIR)%.$(DEP_EXT): $(SRC_DIR)%.$(SRC_EXT)
	@mkdir -p $(dir $@)
	@$(eval TMP_FILE := $(patsubst %.$(DEP_EXT), %.$(TMP_EXT), $@))
	@$(CC) -MM $< > $(TMP_FILE)
	@(echo -n $(OBJ_DIR) && cat $(TMP_FILE)) > $@
	@rm -f $(TMP_FILE)
include $(DEP_FILES)
