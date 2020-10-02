# ================================== MACROS ============================================================================
# Recursive wildcard macro
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# ================================== CONSTANTS =========================================================================
OBJ_FOLDER := obj/
COMP_FOLDER := components/
BIN_FOLDER := bin/

# ================================== VARIABLES FROM MACROS =============================================================
SRC_FILES := $(call rwildcard,$(COMP_FOLDER),*.c)
OBJ_NAMES := $(patsubst $(COMP_FOLDER)%.c, %.o, $(SRC_FILES))
OBJ_FILES := $(addprefix $(OBJ_FOLDER), $(OBJ_NAMES))

# ================================== TARGETS ===========================================================================
all:components/main.c
	@gcc -Wall -o bin/exec.bin components/main.c components/strings/src/strings.c components/math/mathematics.c
clean:
	@rm -rf obj/*.o bin/*.bin
run:all
	@bin/exec.bin
print:
	@echo $(SRC_FILES)
	@echo $(OBJ_FILES)
