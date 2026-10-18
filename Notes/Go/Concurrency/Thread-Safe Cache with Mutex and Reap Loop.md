## Thread-Safe Cache with Periodic Eviction

```go
type cacheEntry struct {
    createdAt time.Time
    val       []byte
}

type Cache struct {
    entries map[string]cacheEntry
    mu      *sync.Mutex
}

func NewCache(interval time.Duration) *Cache {
    c := &Cache{
        entries: make(map[string]cacheEntry),
        mu:      &sync.Mutex{},
    }
    go c.reapLoop(interval)
    return c
}

func (c *Cache) Add(key string, val []byte) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.entries[key] = cacheEntry{createdAt: time.Now(), val: val}
}

func (c *Cache) Get(key string) ([]byte, bool) {
    c.mu.Lock()
    defer c.mu.Unlock()
    entry, ok := c.entries[key]
    if !ok { return nil, false }
    return entry.val, true
}

func (c *Cache) reapLoop(interval time.Duration) {
    ticker := time.NewTicker(interval)
    for range ticker.C {
        c.mu.Lock()
        cutoff := time.Now().Add(-interval)
        for k, e := range c.entries {
            if e.createdAt.Before(cutoff) { delete(c.entries, k) }
        }
        c.mu.Unlock()
    }
}
```

- **Pointer receiver** (`*Cache`) required: mutates map and avoids copying `sync.Mutex`.
- **`defer Unlock`** in short-lived methods (`Add`, `Get`) guarantees release on all return paths.
- **Explicit `Unlock`** in `reapLoop` loop body; `defer` would wait for function exit (never), causing deadlock.
- **`make`** initializes map; nil map assignment panics.