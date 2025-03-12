import ctypes
from ctypes import CDLL, POINTER, c_double, c_int
from collections import defaultdict
from typing import Tuple, List

class VectorDatabase:
    def __init__(self):
        self.vectors = {}
        self.load_library()

    def load_library(self):
        self.mylib = CDLL('./mylib.so')
        self.mylib.py_dot_product.argtypes = [POINTER(c_double), POINTER(c_double), c_int]
        self.mylib.py_dot_product.restype = c_double

        self.mylib.py_vector_norm.argtypes = [POINTER(c_double), c_int]
        self.mylib.py_vector_norm.restype = c_double

    def insert(self, key: str, vector: List[float]) -> None:
        self.vectors[key] = vector

    def retrieve(self, key: str) -> List[float]:
        return self.vectors.get(key, None)

    def cosine_similarity(self, v1: List[float], v2: List[float]) -> float:
        # Convert lists to ctypes arrays
        v1_array = (c_double * len(v1))(*v1)
        v2_array = (c_double * len(v2))(*v2)

        # Use ctypes to call the assembly dot product function
        dot_product = self.mylib.py_dot_product(v1_array, v2_array, len(v1))
        
        # Calculate norms using assembly function
        norm_v1 = self.mylib.py_vector_norm(v1_array, len(v1))
        norm_v2 = self.mylib.py_vector_norm(v2_array, len(v2))

        if norm_v1 == 0 or norm_v2 == 0:
            return 0.0
        return dot_product / (norm_v1 * norm_v2)

    def search(self, query_vector: List[float], k: int) -> List[Tuple[str, float]]:
        similarities = [(key, self.cosine_similarity(query_vector, vector)) for key, vector in self.vectors.items()]
        similarities.sort(key=lambda x: x[1], reverse=True)
        return similarities[:k]
