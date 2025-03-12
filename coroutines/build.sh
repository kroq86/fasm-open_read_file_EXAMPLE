#!/bin/bash
set -e  # Exit on error

# Compile assembly
fasm switch.asm

# Compile C wrapper with position independent code
gcc -fPIC -c wrapper.c -o wrapper.o

# Link everything into shared library
gcc -shared -o libcoroutines.so switch.o wrapper.o -lc

# Make executable and run
chmod +x coroutine.py
python3 coroutine.py 