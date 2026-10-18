## Map Key Existence and Deletion

**Check existence (comma ok):**

```go
val, ok := myMap[key]
if ok {
    // key exists, val is the value
}

// Existence only
if _, ok := myMap[key]; ok {
    // key exists
}
```

**Delete key:**

```go
delete(myMap, key) // no-op if key absent
```

**In cache reap loop:**

```go
c.mu.Lock()
for k, e := range c.entries {
    if time.Since(e.createdAt) > interval {
        delete(c.entries, k)
    }
}
c.mu.Unlock()
```

- `delete` is safe on nil maps and missing keys.
- Iterate with `range` while holding mutex; deleting during iteration is safe in Go.