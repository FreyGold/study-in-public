# Go HTTP Middleware Guard Pattern

A Go middleware guard takes the next handler once at setup and returns a new handler. The new handler runs a check first, then calls `next` only if the check passes.

```go
func guard(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if !loggedIn(r) {
            w.WriteHeader(401)
            return
        }
        next.ServeHTTP(w, r)
    })
}
```

Usage:

```go
http.Handle("/profile", guard(profileHandler))
```

The router only accepts handlers, so the guard must return a handler. It receives `next` once, remembers it, and returns the per-request handler.

Without wrapping, the same check is pasted into every handler. Wrapping writes the check once and makes it harder to forget a route.

This is the same idea as Express `next()`; Go spells it out explicitly because functions return functions.