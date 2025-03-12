import ctypes

mylib = ctypes.CDLL('./mylib.so')
mylib.py_add.argtypes = [ctypes.c_int, ctypes.c_int]
mylib.py_add.restype = ctypes.c_int

result = mylib.py_add(5, 7)
print("Result:", result)
