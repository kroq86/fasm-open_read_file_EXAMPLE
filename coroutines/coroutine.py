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

lib.python_generator_yield.argtypes = [ctypes.c_void_p]
lib.python_generator_yield.restype = ctypes.c_void_p

GENERATOR_FUNC = ctypes.CFUNCTYPE(None, ctypes.c_void_p)

class Generator(GeneratorStruct):
    def __init__(self, func):
        super().__init__()
        self.fresh = True
        self.dead = False
        self.func_obj = GENERATOR_FUNC(func)  # Keep reference to prevent GC
        self.func = ctypes.cast(self.func_obj, ctypes.c_void_p).value
        
        # We don't actually use the stack in our simplified implementation
        self.stack_base = 0
        self.rsp = 0
        
        print(f"Created generator with func at {hex(self.func)}")
    
    def __str__(self):
        return f"Generator(fresh={self.fresh}, dead={self.dead}, func={hex(self.func)})"
    
    def next(self, arg=None):
        """Send a value to the generator and get the next yielded value."""
        if self.dead:
            print(f"Generator is dead, returning None")
            return None
        
        try:
            # For the first call, pass self as the argument to the generator function
            if self.fresh:
                print(f"First call to generator: {self}")
                return lib.python_generator_next(ctypes.byref(self), ctypes.byref(self))
            else:
                # For subsequent calls, pass the provided argument
                print(f"Resuming generator with arg: {arg}")
                return lib.python_generator_next(ctypes.byref(self), 
                                               ctypes.c_void_p(arg) if arg is not None else None)
        except Exception as e:
            # Mark the generator as dead if an exception occurs
            self.dead = True
            print(f"Exception in generator: {e}")
            return None

def example_generator(arg):
    try:
        # Convert the argument to a generator pointer
        gen_ptr = ctypes.cast(arg, ctypes.c_void_p).value
        print(f"Generator started with arg: {hex(gen_ptr) if gen_ptr else 'NULL'}")
        
        # Yield a value and get the first argument from the caller
        result = lib.python_generator_yield(ctypes.c_void_p(1))
        print(f"Generator resumed with arg: {result}")
        
        # Yield another value and get the second argument from the caller
        result = lib.python_generator_yield(ctypes.c_void_p(2))
        print(f"Generator resumed with arg: {result}")
        
        # Yield a third value and get the third argument from the caller
        result = lib.python_generator_yield(ctypes.c_void_p(3))
        print(f"Generator resumed with arg: {result}")
        
        print("Generator finished")
    except Exception as e:
        print(f"Exception in generator function: {e}")
    finally:
        # Mark the generator as dead if needed
        if arg:
            try:
                gen = ctypes.cast(arg, ctypes.POINTER(GeneratorStruct))
                if gen:
                    gen.contents.dead = True
                    print(f"Marked generator as dead: {gen.contents.dead}")
            except Exception as e:
                print(f"Error marking generator as dead: {e}")

# Initialize the generator system
lib.python_generator_init()

# Create generator
print("\n=== Creating generator ===")
gen = Generator(example_generator)

# Start generator
print("\n=== Starting generator ===")
result = gen.next(None)
print(f"Main got: {result}")

# Resume generator with different values
print("\n=== Resuming generator with 42 ===")
result = gen.next(42)
print(f"Main got: {result}")

print("\n=== Resuming generator with 84 ===")
result = gen.next(84)
print(f"Main got: {result}")

print("\n=== Resuming generator with 126 ===")
result = gen.next(126)
print(f"Main got: {result}")

# One more call should return None since generator is finished
print("\n=== Final call (generator should be dead) ===")
result = gen.next(0)
print(f"Main got: {result}")

print("\n=== Done ===")