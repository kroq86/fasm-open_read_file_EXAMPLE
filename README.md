Fasm - https://flatassembler.net/  
Linux SYS_calls - https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md  
  
HOW TO DEBUG:  

gdb Frontend  - https://github.com/nakst/gf  
int3 - in code to set breakpoint  
readelf -h <binary> // start point  
``` 
$ fasm mycat.asm  
$ chmod +x ./mycat  
$ ./mycat  
```
