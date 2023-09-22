# mycat.asm

Fasm - https://flatassembler.net/  
Linux SYS_calls - https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md  
  
> [!HOW TO DEBUG]
> gdb Frontend  - https://github.com/nakst/gf  
> int3 - in code to set breakpoint  
> readelf -h BINARY // start point  
![elf](https://github.com/kroq86/fasm-open_read_file_EXAMPLE/assets/29804069/222c37f7-8bb2-4a23-bbbd-8e3167d446c4)

``` 
$ fasm mycat.asm  
$ chmod +x ./mycat  
$ ./mycat  
```
