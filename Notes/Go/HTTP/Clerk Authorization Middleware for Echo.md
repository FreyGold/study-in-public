# Clerk Authorization Middleware for Echo

Clerk's `clerkhttp` package uses standard `net/http` types (`http.Handler`, `http.ResponseWriter`, `*http.Request`), not Echo's `echo.Context`. Echo bridges them with `echo.WrapMiddleware`.

Chain, inside out:

- `http.HandlerFunc(yourFunc)` labels a plain function as `http.Handler`. It is a type conversion, not a call; `w` and `r` do not exist yet.
- `clerkhttp.AuthorizationFailureHandler(handler)` returns an `AuthorizationOption`: "use this when auth fails."
- `clerkhttp.WithHeaderAuthorization(option)` returns net/http middleware: `func(http.Handler) http.Handler`.
- `echo.WrapMiddleware(...)` returns Echo middleware: `echo.MiddlewareFunc` (`func(echo.HandlerFunc) echo.HandlerFunc`).
- `echo.WrapMiddleware(...)(func(c echo.Context) error {...})` immediately invokes the middleware with the success handler and returns the final `echo.HandlerFunc`.

Echo creates `c` per request; you never construct it. Clerk claims are read via `c.Request().Context()`.

`RequireAuth` has the shape `func(echo.HandlerFunc) echo.HandlerFunc`, so Echo passes `next` automatically when used with `api.Use`.

Apply to routes:

```go
api := e.Group("/api")
api.Use(auth.RequireAuth)
api.GET("/profile", getProfile)

e.GET("/health", healthHandler) // public, outside the group
```

Code review catch: in the failure handler, an `else` branch logged "could not get session claims from context" on the JSON-encode success path; that message belongs in the `if !ok` block.