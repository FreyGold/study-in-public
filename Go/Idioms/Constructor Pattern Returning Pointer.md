## Exported Constructor Returning Pointer

```go
func NewCache(interval time.Duration) *Cache {
    c := &Cache{
        entries: make(map[string]cacheEntry),
        mu:      &sync.Mutex{},
    }
    go c.reapLoop(interval)
    return c
}
```

- **Capital `New`**: Exported name allows external packages to create instance.
- **Return `*Cache`**: Callers receive same instance with initialized map/mutex; avoids copying mutex.
- **`make` map**: Prevents panic on first write to nil map.
- **Start goroutine immediately**: `go c.reapLoop(interval)` begins cleanup without caller action.
- **Pointer to mutex**: `&sync.Mutex{}` ensures single mutex instance shared across all methods.