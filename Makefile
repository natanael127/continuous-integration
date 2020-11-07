# ================================== CUSTOMIZED MACROS =================================================================
# Recursive wildcard macro
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# ================================== VARIABLES FROM SHELL COMMANDS =====================================================
GIT_DESCRIPTION_STR := $(shell git describe --dirty=-dirty)
GIT_COMMIT_HASH_STR := $(shell git rev-parse --short HEAD)
GIT_TAGS := $(shell git tag)

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
PRJ_FLAGS = -D_GIT_DESCRIPTION_STR=\"$(GIT_DESCRIPTION_STR)\" -D_GIT_COMMIT_HASH_STR=\"$(GIT_COMMIT_HASH_STR)\"
TEST_FLAGS := -D_TEST_MODE
# Static analysis
LST_NAME := project
STC_NAME := static
CPX_NAME := complexity
COMPLEXITY_GLOBAL_THRESHOLD := 0
# Git
GIT_MAIN_BRANCH := master

# ================================== VARIABLES FROM MACROS =============================================================
BIN_FILE := $(BIN_DIR)$(BIN_NAME).$(BIN_EXT)                                            # Resulted binary
SRC_FILES := $(call rwildcard,$(SRC_DIR),*.$(SRC_EXT))                                  # Sources
HDR_FILES := $(call rwildcard,$(SRC_DIR),*.$(HDR_EXT))                                  # Headers
OBJ_FILES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), $(OBJ_DIR)%.$(OBJ_EXT), $(SRC_FILES))   # Objects
DEP_FILES := $(patsubst $(SRC_DIR)%.$(SRC_EXT), $(DEP_DIR)%.$(DEP_EXT), $(SRC_FILES))   # Dependency files
TAG_FILES := $(patsubst %, $(TAG_DIR)%.$(BIN_EXT), $(GIT_TAGS))     # List of release files
LST_FILE := $(ANL_DIR)$(LST_NAME).$(LST_EXT)                        # JSON compile database for cppcheck
STC_FILE := $(ANL_DIR)$(STC_NAME).$(ANL_EXT)                        # Cppcheck general report
CPX_FILE := $(ANL_DIR)$(CPX_NAME).$(ANL_EXT)                        # Complexity general report

# ================================== TARGETS ===========================================================================
# ---------------------------------- USER TARGETS ----------------------------------------------------------------------
# Building and testing processes
all: $(OBJ_FILES)                                                   # Main target (just builds the binary)
	@echo Linking objects to \"$(BIN_FILE)\"
	@mkdir -p $(BIN_DIR)                                            # Creates directory if doesn't exist
	@$(CC) $(C_FLAGS) -o $(BIN_FILE) $(OBJ_FILES)                   # Links object files to binary
clean:                                                              # Cleans all files related to build and analysis
	@rm -rf $(BUILD_DIR)
run: all                                                            # Runs application after building it
	@echo Running the application
	@echo =========================================================
	@$(BIN_FILE)
test: clean test_setup run                                          # Run application for tests
# Code quality
format:                                                             # Applies formatting rules
	@clang-format --style=file -i $(SRC_FILES) $(HDR_FILES)         # Uses clang-format with customized template
analysis:                                                           # Static and complexity analysis
	@mkdir -p $(ANL_DIR)                                            # Creates directory if doesn't exist
	@ # Runs make without actually calling gcc and creates a JSON compile database
	@make --always-make --dry-run |\
	grep -wE 'gcc|g++' | grep -w '\-c' |\
	jq -nR '[inputs|{directory:".", command:., file: match(" [^ ]+$$").string[1:]}]' > $(LST_FILE)
	@cppcheck --quiet --enable=all --project=$(LST_FILE) --output-file=$(STC_FILE)
	@complexity --histogram --score --thresh=$(COMPLEXITY_GLOBAL_THRESHOLD) $(SRC_FILES) > $(CPX_FILE)
	@cat $(STC_FILE)                                                # Display analysis of 'cppcheck'
	@cat $(CPX_FILE)                                                # Display analysis of 'complexity'
# Binary organization
descripted: all                                                     # Creates a git-descripted binary
	@mkdir -p $(OTR_DIR)
	@cp "$(BIN_FILE)" "$(OTR_DIR)$(GIT_DESCRIPTION_STR).$(BIN_EXT)" # Copies built binary to a descripted place
releases: save_work $(TAG_FILES)                                    # Creates all releases from tags (incrementally)
	@echo Releases successfully generated!
# ---------------------------------- INTERNAL TARGETS ------------------------------------------------------------------
not_dirty: force_not_dirty all                                      # Removes 'dirty' signal in a controled way...
force_not_dirty:                                                    # because just the Makefile won't be over the tag
	@$(eval GIT_DESCRIPTION_STR := $(shell git describe))
save_work:                                                          # Stashes any possible change before 'checkouts'
	@git stash save -u --quiet "Saved from make process"
test_setup:                                                         # Appends TEST_FLAGS to build definitions
	@$(eval PRJ_FLAGS += $(TEST_FLAGS))
# ---------------------------------- FILE TARGETS ----------------------------------------------------------------------
$(TAG_DIR)%.$(BIN_EXT):                                             # Creates the specific release file
	@mkdir -p $(TAG_DIR)                                            # Creates directory if doesn't exist
	@$(eval THE_TAG := $(patsubst $(TAG_DIR)%.$(BIN_EXT),%, $@))    # Extracts the tag from intended release file
	@git submodule --quiet deinit --all                             # Disables submodules for 'checkout'
	@git checkout --quiet $(THE_TAG)                                # Goes to tag status
	@git submodule --quiet update --init --recursive                # Enables just the required submodules for that tag
	@git checkout --quiet $(GIT_MAIN_BRANCH) -- Makefile .gitignore # Restores essential files from main branch (1)
	@git clean --quiet -fd                                          # Cleans any nonexistent file in that tag
	@make -s clean                                                  # Cleans the build files (avoid wrong descriptions)
	@make -s not_dirty                                              # Builds without word 'dirty' due to (1)
	@git submodule --quiet deinit --all                             # Disables submodules for 'checkout'
	@git checkout --quiet $(GIT_MAIN_BRANCH)                        # Goes back to main branch
	@git submodule --quiet update --init --recursive                # Enables the required submodules for main branch
	@cp "$(BIN_FILE)" "$(TAG_DIR)$(THE_TAG).$(BIN_EXT)"             # Copies binary file to release organization dir
	@echo Released tag: $(THE_TAG)
	@echo =========================================================
$(OBJ_DIR)%.$(OBJ_EXT): $(SRC_DIR)%.$(SRC_EXT) $(DEP_DIR)%.$(DEP_EXT)   # Builds the specific file object
	@echo Building \"$@\" from \"$<\"
	@$(eval CPX_INDIVIDUAL_FILE := $(patsubst $(OBJ_DIR)%.$(OBJ_EXT),$(CPX_DIR)%.$(ANL_EXT), $@))
	@mkdir -p $(dir $(CPX_INDIVIDUAL_FILE))                             # Organizes obj. files in same directory...
	@mkdir -p $(dir $@)                                                 # structure as the source files
	@$(CC) $(C_FLAGS) $(PRJ_FLAGS) -c -o $@ $<
	@complexity --histogram --score --trace=$(CPX_INDIVIDUAL_FILE) --thresh=$(COMPLEXITY_GLOBAL_THRESHOLD) $< >> $(CPX_INDIVIDUAL_FILE)                                                   # Creates individual complexity report
$(DEP_DIR)%.$(DEP_EXT): $(SRC_DIR)%.$(SRC_EXT)                          # Creates dependency file
	@mkdir -p $(dir $@)                                                 # Creates directory if doesn't exist
	@$(eval TMP_FILE := $(patsubst %.$(DEP_EXT), %.$(TMP_EXT), $@))     # Temporary file for holding information
	@$(CC) -MM $< > $(TMP_FILE)                                         # Depency generation
	@(echo -n $(OBJ_DIR) && cat $(TMP_FILE)) > $@                       # Concatenates the predecessor path to .d file
	@rm -f $(TMP_FILE)                                                  # Deletes temporary file
include $(DEP_FILES)                                                    # Dependency files for complex dependencies
