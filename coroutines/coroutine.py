import ctypes
import os

try:
    # Load the shared library
    lib = ctypes.CDLL('./libcoroutines.so')
except OSError as e:
    print(f"Error loading library: {e}")
    exit(1)

class GeneratorStruct(ctypes.Structure):
    _fields_ = [
        ("fresh", ctypes.c_bool),
        ("dead", ctypes.c_bool),
        ("_padding", ctypes.c_char * 6),  # Align to 8 bytes
        ("rsp", ctypes.c_void_p),
        ("stack_base", ctypes.c_void_p),
        ("func", ctypes.c_void_p),
    ]

lib.python_generator_init.argtypes = []
lib.python_generator_init.restype = None

lib.python_generator_next.argtypes = [ctypes.POINTER(GeneratorStruct), ctypes.c_void_p]
lib.python_generator_next.restype = ctypes.c_void_p

lib.python_generator_restore_context.argtypes = [ctypes.c_void_p]
lib.python_generator_restore_context.restype = None

lib.python_generator_restore_context_with_return.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
lib.python_generator_restore_context_with_return.restype = None

lib.python_generator_yield.argtypes = [ctypes.c_void_p]
lib.python_generator_yield.restype = ctypes.c_void_p

GENERATOR_FUNC = ctypes.CFUNCTYPE(None, ctypes.c_void_p)

STACK_CAPACITY = 1024 * os.sysconf('SC_PAGE_SIZE')  # Match the C implementation

class Generator(GeneratorStruct):
    def __init__(self, func):
        super().__init__()
        self.fresh = True
        self.dead = False
        self.func_obj = GENERATOR_FUNC(func)  # Keep reference to prevent GC
        self.func = ctypes.cast(self.func_obj, ctypes.c_void_p).value
        
        # Allocate stack
        self.stack_memory = (ctypes.c_uint8 * STACK_CAPACITY)()
        self.stack_base = ctypes.addressof(self.stack_memory)
        self.rsp = self.stack_base + STACK_CAPACITY - 16
        self.rsp = self.rsp - (self.rsp % 16)  # 16-byte alignment
    
    def next(self, arg=None):
        """Send a value to the generator and get the next yielded value."""
        if self.dead:
            return None
        
        if self.fresh:
            # First call, use generator_next
            # Pass self as the argument to the generator function
            return lib.python_generator_next(ctypes.byref(self), 
                                           ctypes.byref(self) if arg is None else ctypes.c_void_p(arg))
        else:
            # Resume with a value
            return lib.python_generator_yield(ctypes.c_void_p(arg) if arg is not None else None)

def example_generator(arg):
    try:
        print("Generator started")
        result = lib.python_generator_yield(ctypes.c_void_p(1))
        print(f"Generator resumed with {result}")
        result = lib.python_generator_yield(ctypes.c_void_p(2))
        print(f"Generator resumed with {result}")
        print("Generator finished")
    finally:
        # Mark the generator as dead
        # This is a hack to ensure the generator is properly marked as dead
        # since we're bypassing the normal generator_finish_current mechanism
        gen = ctypes.cast(arg, ctypes.POINTER(GeneratorStruct))
        if gen:
            gen.contents.dead = True

# Initialize the generator system
lib.python_generator_init()

# Create generator
gen = Generator(example_generator)

# Start generator
print("Starting generator")
result = gen.next(None)
print(f"Main got {result}")

# Resume generator twice
print("Resuming generator")
result = gen.next(42)
print(f"Main got {result}")

print("Resuming generator again")
result = gen.next(84)
print(f"Main got {result}")

# One more call should return None since generator is finished
print("Final call")
result = gen.next(0)
print(f"Main got {result}")