fasm bs.asm bs.o   
gcc -c wrapper.c -o wrapper.o   
gcc -shared -o mylib.so bs.o wrapper.o 
python bs.py          