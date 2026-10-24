# Logger Service — New Relic and zerolog setup

`LoggerService` wraps a New Relic `Application` and centralizes observability for the Go backend.

- `NewLoggerService` creates the New Relic app only when a license key exists. On a missing key or init error it returns `nrApp == nil`, so the app runs without New Relic (graceful degradation).
- `Shutdown()` flushes buffered data to New Relic for up to 10 seconds before the process exits.
- `GetApplication()` exposes the app so HTTP middleware can start transactions.

`NewLoggerWithService` builds the main `zerolog.Logger`:
- Maps config level to a zerolog level, defaulting to `info`; does not call `zerolog.SetGlobalLevel`, so each logger keeps its own level.
- Production + JSON writes to `os.Stdout` through New Relic's `zerologWriter`, which forwards logs and still prints to stdout.
- Development uses a colorized `ConsoleWriter`.
- Every line carries `service` and `environment`; stack traces are added only outside production.

`WithTraceContext(logger, txn)` adds `trace.id` and `span.id` from a New Relic transaction so logs can be matched to a request trace.

`NewPgxLogger` creates a separate `component=database` logger that truncates SQL over 200 chars and pretty-prints JSON `[]byte` values.

`GetPgxTraceLogLevel` translates zerolog levels into pgx's numeric tracelog scale.