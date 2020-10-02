all:components/main.c
	@gcc -Wall -o bin/exec.bin components/main.c components/strings/src/strings.c components/math/mathematics.c
clean:
	@rm -rf obj/*.o bin/*.bin
run:all
	@bin/exec.bin
