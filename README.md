# Dependencies
In order to perform static analysis and code formatting, some dependencies must be installed
```
sudo apt-get install jq complexity cppcheck clang-format
```

# Makefile targets
Some targets were designed for the user, other were created for internal use.

Here will be described the user targets, which must be used like:
```
make <target_name>
```

## Building processes
### all
Builds the project and creates the binary at path ```BIN_FILE```
### clean
Cleans all build products, removing the directory ```BUILD_DIR```
### run
The same as ```all```, but after building, runs the application directly
### test
Automated test routine, here it compiles the code using the directive ```TEST_MODE```

## Code quality
### format
Formats the header and source files using the tool ```clang-format``` according to template file ```.clang-format```
### analysis
Uses tools ```cppcheck``` and ```complexity``` to give reports about the code

## Binary organization
### descripted
Creates a git-descripted binary of current state of project inside directory ```OTR_DIR```
### releases
Creates all missing release files to path ```TAG_DIR```
