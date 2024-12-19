# Compiler and tools
CC = gcc
ZIG = zig
CFLAGS = -Wall -Wextra -O2 -I./src
LDFLAGS = 

# Files
BISON_FILE = src/parser.y
LEX_FILE = src/lexer.l
ZIG_FILE = src/main.zig
PARSER_OBJECTS = src/parser.o
LEXER_OBJECTS = src/lexer.o
INTERFACE_OBJECTS = src/parser_interface.o
C_OBJECTS = $(LEXER_OBJECTS) $(PARSER_OBJECTS) $(INTERFACE_OBJECTS)
EXECUTABLE = main

# Bison and Flex generated files
PARSER_C = src/parser.c
PARSER_H = src/parser.tab.h
LEXER_C = src/lexer.c

# Default target
all: $(EXECUTABLE)

generate: $(PARSER_C) $(PARSER_H) $(LEXER_C) $(C_OBJECTS)

# Build the Zig executable and link with the C objects
$(EXECUTABLE): $(C_OBJECTS) $(ZIG_FILE)
	$(ZIG) build-exe $(ZIG_FILE) $(C_OBJECTS) -femit-bin=$(EXECUTABLE)

# Compile the Bison-generated C parser
src/parser.o: $(PARSER_C)
	$(CC) $(CFLAGS) -c $(PARSER_C) -o $@

# Compile the Flex-generated C lexer
src/lexer.o: $(LEXER_C) $(PARSER_H)
	$(CC) $(CFLAGS) -c $(LEXER_C) -o $@

# Compile the parser interface
src/parser_interface.o: src/parser_interface.c $(PARSER_H)
	$(CC) $(CFLAGS) -c src/parser_interface.c -o $@

# Generate parser.c and parser.tab.h from parser.y using Bison
$(PARSER_C) $(PARSER_H): $(BISON_FILE)
	cd src && bison -d $(notdir $(BISON_FILE))
	cd src && mv parser.tab.c parser.c

# Generate lexer.c from lexer.l using Flex
$(LEXER_C): $(LEX_FILE) $(PARSER_H)
	flex -o $(LEXER_C) $(LEX_FILE)

# Clean up generated files
clean:
	rm -f $(EXECUTABLE) $(C_OBJECTS) $(PARSER_C) $(PARSER_H) $(LEXER_C)

.PHONY: all clean generate
