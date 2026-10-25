# HTTP Request Context and Echo

There is no special **http.Context** type. The type is **context.Context**.

The Go HTTP server creates a context for each request. It detects a client disconnection and cancels that context.

~~~text
Client disconnects
        |
        v
HTTP server cancels request context
~~~

Your code does not cancel the root request context. The HTTP server owns it. Your code gets it and passes it down.

~~~go
func handler(
    w http.ResponseWriter,
    r *http.Request,
) {
    ctx := r.Context()
}
~~~

## Echo

An Echo handler has this form:

~~~go
func handler(c echo.Context) error
~~~

**echo.Context** is Echo's handler object. It is not **context.Context**.

Get the Go request context through Echo:

~~~go
func handler(c echo.Context) error {
    ctx := c.Request().Context()
    return service.DoWork(ctx)
}
~~~

A timed child can stop on user disconnection or on its own timeout:

~~~go
ctx, cancel := context.WithTimeout(
    c.Request().Context(),
    5*time.Second,
)
defer cancel()
~~~
