# FASM Examples and Learning Repository

A comprehensive collection of FASM (Flat Assembler) examples, utilities, and learning resources for x86_64 assembly programming on Linux.

## Repository Structure

```
.
├── Core Files
│   ├── common.inc          # Core macros and utilities
│   ├── linux.inc           # Linux syscall definitions
│   └── debug.inc           # Debug helpers and macros
│
├── Basic Examples
│   ├── mycat.asm           # File reading example
│   ├── arg.asm             # Command line args
│   ├── fib.asm             # Fibonacci sequence
│   ├── two_sum.asm         # Two sum algorithm
│   └── file_ops.asm        # File operations
│
├── Advanced Examples
│   ├── add/                # Addition operations
│   │   ├── add.asm
│   │   ├── add.py          # Python wrapper
│   │   ├── readme.md
│   │   └── wrapper.c       # C wrapper
│   │
│   ├── binary_search/      # Binary search implementation
│   │   ├── bin_s.asm
│   │   ├── bin_s.py
│   │   ├── readme.md
│   │   └── wrapper/        # Wrapper implementations
│   │
│   ├── cadd/               # C-integrated addition
│   │   ├── add.c
│   │   ├── add.py
│   │   └── run.sh
│   │
│   ├── coroutines/         # Coroutine examples
│   │   ├── build.sh
│   │   ├── coroutine.py
│   │   ├── readme.md
│   │   ├── switch.asm
│   │   └── wrapper.c
│   │
│   └── vec/                # Vector operations
│       ├── dot_product.asm
│       ├── readme.md
│       ├── vec.py
│       └── wrapper.c
│
├── Documentation
│   ├── AI_FASM_RULES.md        # AI coding guidelines
│   └── FASM_REFERENCE_GUIDE.md # FASM reference
│
└── Test Files
    ├── test.txt            # Test data
    ├── lol.txt             # Additional test data
    └── output.txt          # Output example
```

## Key Features

- **Common Include Files**: Reusable macros and utilities for FASM programming
- **Example Programs**: From basic to advanced assembly concepts
- **System Programming**: File operations, process management, and more
- **Algorithm Implementations**: Common algorithms in assembly
- **Language Integration**: Python and C wrappers for assembly code
- **Documentation**: Comprehensive guides and references

## Getting Started

1. Install FASM:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install fasm
   
   # Arch Linux
   sudo pacman -S fasm
   ```

2. Build a basic example:
   ```bash
   # File reading example
   fasm mycat.asm
   chmod +x mycat
   ./mycat
   
   # Or try fibonacci calculator
   fasm fib.asm
   chmod +x fib
   ./fib
   ```

## Documentation

- [AI FASM Rules](AI_FASM_RULES.md) - Guidelines for AI-assisted FASM programming
- [FASM Reference Guide](FASM_REFERENCE_GUIDE.md) - Comprehensive FASM reference guide

## Example Categories

### Basic Examples
- `mycat.asm` - File reading and writing
- `arg.asm` - Command line argument handling
- `fib.asm` - Fibonacci sequence calculator
- `two_sum.asm` - Two sum algorithm implementation
- `file_ops.asm` - Advanced file operations

### Advanced Examples
Each advanced example includes its own README with build and usage instructions:
- [Addition Operations](add/readme.md) - FASM with Python/C integration
- [Binary Search](binary_search/readme.md) - Search implementation with wrappers
- [Coroutines](coroutines/readme.md) - Assembly coroutines with Python
- [Vector Operations](vec/readme.md) - SIMD/Vector processing examples

## Features by Category

### System Programming
- File operations (open, read, write, close)
- Command line argument handling
- System calls with error checking

### Language Integration
- Python wrappers
- C integration
- Build scripts

### Algorithms
- Two Sum problem
- Binary Search
- Vector operations
- Fibonacci sequence

### Advanced Concepts
- SIMD operations
- Coroutines
- Cross-language integration

## Debugging

> gdb Frontend  - https://github.com/nakst/gf  
> int3 - in code to set breakpoint  
> readelf -h BINARY // start point  
![elf](https://github.com/kroq86/fasm-handbook/assets/29804069/222c37f7-8bb2-4a23-bbbd-8e3167d446c4)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.