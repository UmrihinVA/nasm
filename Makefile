ASM = nasm
CC = gcc
CFLAGS =
ASMFLAGS = -g -f elf64 -F dwarf
ASMTARGETS = fib.asm

all: fib

fib: fib.o
	$(CC) $(CFLAGS) $^ -o $@

fib.o: $(ASMTARGETS)
	$(ASM) $(ASMFLAGS) $^ -o $@

.PHONY: clean
clean:
	rm -rf *.o out
