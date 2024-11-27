# MAIN
main: main.o
	ld main.o -static -o main

main.o: main.nasm
	nasm -f elf64 -g main.nasm


# HELLO-WORLD
hello_world: hello_world.o print_hw.o
	ld hello_world.o print_hw.o -static -o hello_world

hello_world.o: hello_world.nasm
	nasm -f elf64 -g hello_world.nasm

print_hw.o: print_hw.nasm
	nasm -f elf64 -g print_hw.nasm

# OTHER
clean:
	rm -f $(shell cat .gitignore)

.PHONY: clean
