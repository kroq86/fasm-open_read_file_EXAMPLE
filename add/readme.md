fasm add.asm add.o
gcc -c wrapper.c -o wrapper.o
gcc -shared -o mylib.so add.o wrapper.o
