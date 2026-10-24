# ObservabilityConfig

`ObservabilityConfig` is the settings object for observability, loaded from environment variables at startup.

Fields:
- `ServiceName`, `Environment`
- `Logging.Level`, `Logging.Format`, `Logging.SlowQueryThreshold`
- `NewRelic.LicenseKey`, `AppLogForwardingEnabled`, `DistributedTracingEnabled`, `DebugLogging`
- `HealthChecks.Enabled`, `Interval`, `Timeout`, `Checks`

`Validate()` requires a non-empty service name, accepts only debug/info/warn/error levels, and rejects negative slow-query thresholds. Struct tags handle presence; `Validate()` handles business rules.

`GetLogLevel()` returns `info` for empty production, `debug` for empty development, otherwise the configured level.

`IsProduction()` is true when `Environment == "production"`.

Current consumers:
- Logger service uses service name, environment, log level, format, and New Relic flags.
- New Relic license key is checked in `NewLoggerService`.

Future consumers implied by fields:
- HTTP middleware uses `GetApplication()` to create transactions per request.
- Health checks use `HealthChecks` to ping database/redis on an interval.
- API behavior can branch on `IsProduction()`.