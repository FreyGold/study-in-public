## Mutex Locking Strategy

**Use `defer mu.Unlock()` when:**

- Lock spans entire function (e.g., `Add`, `Get`).
- Multiple return points exist; `defer` guarantees unlock on every path.
- Critical section is short and function exits quickly.

```go
func (c *Cache) Get(key string) ([]byte, bool) {
    c.mu.Lock()
    defer c.mu.Unlock() // unlocks on any return
    entry, ok := c.entries[key]
    if ok { return entry.val, true }
    return nil, false
}
```

**Use explicit `mu.Unlock()` when:**

- Inside long-running loops (`reapLoop`); `defer` would unlock only on function return (never), deadlocking next iteration.
- Critical section is a small subset of function; unlock early to reduce contention.

```go
for range ticker.C {
    c.mu.Lock()
    // scan & delete
    c.mu.Unlock() // unlock each iteration
}
```

- **Rule**: Never `defer` inside a loop that iterates indefinitely.