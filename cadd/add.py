import ctypes

lib = ctypes.CDLL('./libadd.so')

lib.add.argtypes = [ctypes.c_int, ctypes.c_int]
lib.add.restype = ctypes.c_int

result = lib.add(5, 7)
print(f"Result: {result}")
