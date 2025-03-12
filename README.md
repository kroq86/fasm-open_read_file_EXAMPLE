# FASM Examples and Learning Repository

A comprehensive collection of FASM (Flat Assembler) examples, utilities, and learning resources for x86_64 assembly programming on Linux.

## Repository Structure

```
├── include/               # Common include files
│   ├── common.inc        # Main include file with common macros and utilities
│   ├── linux.inc         # Linux-specific syscall definitions
│   └── debug.inc         # Debug helpers and macros
│
├── examples/             # Example programs demonstrating various concepts
│   ├── basics/          # Basic assembly concepts
│   │   ├── hello/       # Hello world example
│   │   └── args/        # Command line arguments
│   │
│   ├── algorithms/      # Algorithm implementations
│   │   ├── sorting/     # Sorting algorithms
│   │   ├── search/      # Search algorithms
│   │   └── math/        # Mathematical operations
│   │
│   ├── system/          # System programming examples
│   │   ├── files/       # File operations
│   │   └── process/     # Process management
│   │
│   └── advanced/        # Advanced concepts
│       ├── simd/        # SIMD/Vector operations
│       └── coroutines/  # Coroutine implementations
│
├── tests/               # Test files and test utilities
│   ├── unit/           # Unit tests for utilities
│   └── data/           # Test data files
│
└── docs/                # Documentation
    ├── AI_FASM_RULES.md     # AI code generation rules
    ├── FASM_REFERENCE.md    # FASM reference guide
    └── examples/            # Example-specific documentation
```

## Key Features

- **Common Include Files**: Reusable macros and utilities for FASM programming
- **Example Programs**: From basic to advanced assembly concepts
- **System Programming**: File operations, process management, and more
- **Algorithm Implementations**: Common algorithms in assembly
- **Documentation**: Comprehensive guides and references

## Getting Started

1. Install FASM:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install fasm
   
   # Arch Linux
   sudo pacman -S fasm
   ```

2. Build an example:
   ```bash
   cd examples/basics/hello
   fasm hello.asm
   ./hello
   ```

## Documentation

- [AI FASM Rules](docs/AI_FASM_RULES.md) - Guidelines for AI-assisted FASM programming
- [FASM Reference](docs/FASM_REFERENCE.md) - Comprehensive FASM reference guide
- [Examples Documentation](docs/examples/) - Detailed documentation for each example

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# mycat.asm

```console 
$ fasm mycat.asm  
$ chmod +x ./mycat  
$ ./mycat  
```

## Quick Start
Fasm - https://flatassembler.net/  
Linux SYS_calls - https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md  
  
## HOW TO DEBUG 
> gdb Frontend  - https://github.com/nakst/gf  
> int3 - in code to set breakpoint  
> readelf -h BINARY // start point  
![elf](https://github.com/kroq86/fasm-open_read_file_EXAMPLE/assets/29804069/222c37f7-8bb2-4a23-bbbd-8e3167d446c4)

---

# FASM Examples Collection

## Repository Structure
```
.
├── Core Files
│   ├── common.inc          # Core macros and utilities
│   └── linux.inc          # Linux syscall definitions
│
├── Basic Examples
│   ├── mycat.asm          # File reading example
│   ├── arg.asm            # Command line args
│   ├── fib.asm            # Fibonacci sequence
│   ├── two_sum.asm        # Two sum algorithm
│   └── file_ops.asm       # File operations
│
├── Advanced Examples
│   ├── add/               # Addition operations
│   │   ├── add.asm
│   │   ├── add.py        # Python wrapper
│   │   ├── readme.md
│   │   └── wrapper.c     # C wrapper
│   │
│   ├── binary_search/     # Binary search implementation
│   │   ├── bin_s.asm
│   │   ├── bin_s.py
│   │   ├── readme.md
│   │   └── wrapper/      # Wrapper implementations
│   │
│   ├── cadd/             # C-integrated addition
│   │   ├── add.c
│   │   ├── add.py
│   │   └── run.sh
│   │
│   ├── coroutines/       # Coroutine examples
│   │   ├── build.sh
│   │   ├── coroutine.py
│   │   ├── readme.md
│   │   ├── switch.asm
│   │   └── wrapper.c
│   │
│   └── vec/              # Vector operations
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
    ├── test.txt          # Test data
    ├── lol.txt           # Additional test data
    └── output.txt        # Output example
```

## Key Components

### Core Files
- `common.inc`: Reusable macros, utilities, and system calls
- `linux.inc`: Linux-specific syscall definitions and constants

### Basic Examples
- File Operations: `mycat.asm`, `file_ops.asm`
- Algorithms: `two_sum.asm`, `fib.asm`
- System: `arg.asm` (command line handling)

### Advanced Examples with Language Integration
1. **Addition Operations** (`add/`)
   - FASM implementation
   - Python and C wrappers
   - Integration examples

2. **Binary Search** (`binary_search/`)
   - Multiple implementations
   - Language wrappers
   - Integration guide

3. **C-Integrated Addition** (`cadd/`)
   - C integration example
   - Build automation

4. **Coroutines** (`coroutines/`)
   - Context switching
   - Python integration
   - Build system

5. **Vector Operations** (`vec/`)
   - SIMD examples
   - Dot product implementation
   - Language integration

### Documentation
- `AI_FASM_RULES.md`: Guidelines for AI-assisted FASM programming
- `FASM_REFERENCE_GUIDE.md`: Comprehensive FASM reference

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.