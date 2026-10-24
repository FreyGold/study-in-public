# pgx MultiTracer Pattern

pgx accepts only one tracer in `ConnConfig.Tracer`. `multiTracer` is a composite that holds `[]any` and forwards every pgx tracing event to each wrapped tracer, so New Relic spans and local logging can run together.

Each tracer is checked with an anonymous type assertion:
```go
if t, ok := tracer.(interface{ TraceQueryStart(...) context.Context }); ok { ... }
```

pgx calls `TraceQueryStart` before a query and `TraceQueryEnd` after. Tracers enrich the returned `context.Context` with data such as start time or a New Relic segment, then read it back on end. This is context chaining.

- `nrpgx5.NewTracer()` opens a New Relic database segment inside the current transaction; queries must pass the request context or they won't appear in traces.
- `pgxzero.NewLogger(pgxLogger)` adapts zerolog to pgx's `tracelog.TraceLog` interface.
- `GetPgxTraceLogLevel` converts the shared config level into pgx's numeric scale so one setting controls both libraries.

Bugs in the source:
- Ping timeout multiplies `DatabasePingTimeout` (already a duration) by `time.Second` again.
- `TraceQueryEnd` asserts a signature that returns a value, but pgx's real `TraceQueryEnd` returns nothing, so end hooks never run.
- On `Ping` failure the pool is not closed, leaking connections.