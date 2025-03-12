fasm switch.asm switch.o
gcc -c wrapper.c -o wrapper.o
gcc -shared -o coroutines.so switch.o wrapper.o
python coroutine.py
