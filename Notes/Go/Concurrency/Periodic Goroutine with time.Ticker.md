## Periodic Background Task with Ticker

```go
func (c *Cache) reapLoop(interval time.Duration) {
    ticker := time.NewTicker(interval)
    for range ticker.C {
        // Critical section: lock, iterate, delete, unlock
        c.mu.Lock()
        cutoff := time.Now().Add(-interval)
        for k, e := range c.entries {
            if e.createdAt.Before(cutoff) { delete(c.entries, k) }
        }
        c.mu.Unlock()
    }
}

// Start at cache creation
go c.reapLoop(interval)
```

- **`time.NewTicker`** returns a channel delivering ticks at `interval`.
- **`go func() { for range ticker.C { ... } }()`** runs loop in background.
- **Pass `interval` parameter**; avoid hardcoded constants (e.g., `5 * time.Second`).
- **Lock per iteration**, not per loop: hold mutex only during map scan/delete.
- **Stop ticker** on shutdown via `ticker.Stop()` (add `done chan struct{}` + `select` for graceful exit if needed).