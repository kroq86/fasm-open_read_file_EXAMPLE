```sh
fasm dot_product.asm dot_product.o
gcc -c wrapper.c -o wrapper.o
gcc -shared -o mylib.so dot_product.o wrapper.o
python vec.py

python example_duckdb.py
```



# DuckDB Vector Database

A high-performance vector similarity search engine built on top of DuckDB, optimized for medium-scale deployments with excellent cache efficiency and multiple search strategies.

- Persistent storage (DuckDB)
- Multiple search algorithms
- Different similarity metrics
- Memory management
- Parallel processing
- Transaction support

![Performance Graph](search_performance.png)

## 🚀 Features

### Core Functionality
- **Multiple Search Methods**
  - Exact Search (100% accuracy)
  - LSH (Locality-Sensitive Hashing)
  - Approximate Search with adaptive sampling
- **Similarity Metrics**
  - Cosine Similarity
  - Euclidean Distance
  - Dot Product
- **Performance Optimizations**
  - Assembly-optimized calculations
  - Intelligent caching (100% hit ratio)
  - Parallel processing
  - Batch operations

### Performance Highlights
- Insert up to 2,300 vectors/second
- Up to 31.78x speedup with approximate search
- Memory efficient: scales down to 10.45KB per vector
- 100% cache hit ratio

## 🛠 Installation

### Prerequisites
- Python 3.8+
- DuckDB
- NumPy
- psutil

```bash
pip install -r requirements.txt
```

### Quick Start

```python
from duckdb_vec import DuckDBVectorDatabase

# Initialize database with 1GB cache
db = DuckDBVectorDatabase(
    db_path="vectors.duckdb",
    chunk_size=1000,
    max_cache_size=1024 * 1024 * 1024
)

# Insert vectors
vectors = [(f"vec_{i}", [1.0, 2.0, 3.0]) for i in range(10)]
db.batch_insert(vectors)

# Search with different methods
query = [1.0, 2.0, 3.0]
exact_results = db.search(query, k=5, method="exact")
approx_results = db.search(query, k=5, method="approximate")
lsh_results = db.search(query, k=5, method="lsh")
```

## 📊 Benchmarks

### Search Performance (100k vectors)
| Method      | Time (s) | Speedup |
|-------------|----------|---------|
| Exact       | 5.1027   | 1.00x   |
| Approximate | 0.1606   | 31.78x  |
| LSH         | 0.4037   | 12.64x  |

### Memory Efficiency
| Dataset Size | Memory/Vector | Cache Hit Ratio |
|-------------|---------------|-----------------|
| 10,000      | 22.78 KB     | 100%           |
| 50,000      | 11.55 KB     | 100%           |
| 100,000     | 10.45 KB     | 100%           |

## 🔧 Configuration

### Database Parameters
```python
DuckDBVectorDatabase(
    db_path=':memory:',              # Database file path
    chunk_size=1000,                 # Partition size
    max_cache_size=1024*1024*1024,   # Cache size in bytes
    similarity_metric="cosine"        # Similarity metric
)
```

### LSH Parameters
```python
LSHIndex(
    num_hash_functions=20,  # Number of hash functions
    num_bands=10           # Number of bands for LSH
)
```

## 📝 API Reference

### Core Methods

#### `insert(key: str, vector: List[float]) -> None`
Insert a single vector with a unique key.

#### `batch_insert(vectors: List[Tuple[str, List[float]]]) -> None`
Insert multiple vectors efficiently.

#### `search(query_vector: List[float], k: int, method: str) -> List[Tuple[str, float]]`
Search for similar vectors using specified method.

#### `get_metrics() -> PerformanceMetrics`
Get current performance metrics.

## 🎯 Use Cases

### Ideal For
- Medium-sized vector collections (10k-100k vectors)
- Local/embedded applications
- SQL-centric workflows
- Low-latency requirements

### Not Recommended For
- Billion+ vector collections
- Distributed systems
- Complex filtering needs
- GPU-accelerated workloads

## 🔍 Examples

### Basic Usage
```python
# See example_duckdb.py for basic usage
python example_duckdb.py

# Run benchmarks
python benchmark_large.py
```

### Advanced Usage
```python
# Initialize with custom settings
db = DuckDBVectorDatabase(
    db_path="vectors.duckdb",
    chunk_size=2000,
    max_cache_size=2*1024*1024*1024,
    similarity_metric="euclidean"
)

# Get performance metrics
metrics = db.get_metrics()
print(f"Cache hit ratio: {metrics.cache_hit_ratio:.2%}")
print(f"Memory usage: {metrics.memory_usage:.2f} MB")
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.


## 📈 Performance Tips

1. **Optimal Cache Size**
   - Set cache size to ~10% of vector data size
   - Monitor cache hit ratio using metrics

2. **Batch Operations**
   - Use batch_insert for multiple vectors
   - Optimal batch size: 1000-5000 vectors

3. **Search Method Selection**
   - Use LSH for balanced speed/accuracy
   - Use approximate search for maximum speed
   - Use exact search for perfect accuracy

## 🙏 Acknowledgments

- DuckDB team for the excellent database engine
- FAISS project for LSH implementation inspiration
- Assembly optimization techniques from various sources