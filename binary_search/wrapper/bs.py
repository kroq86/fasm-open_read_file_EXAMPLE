import ctypes
import numpy as np

mylib = ctypes.CDLL('./mylib.so')

mylib.py_binary_search.argtypes = [ctypes.POINTER(ctypes.c_int), ctypes.c_size_t, ctypes.c_int]
mylib.py_binary_search.restype = ctypes.c_int

arr_np = np.array([1, 3, 5, 7, 9, 11, 13, 15], dtype=np.int32)
arr_ptr = arr_np.ctypes.data_as(ctypes.POINTER(ctypes.c_int))
arr_size = len(arr_np)
search_value = 7

result = mylib.py_binary_search(arr_ptr, arr_size, search_value)
print("Result:", result)
