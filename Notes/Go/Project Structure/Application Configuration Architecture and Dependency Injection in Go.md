### Production Configuration Architecture in Go

Handling configuration in statically typed Go solves distinct problems compared to untyped global environments:

1. **Static Typing & Parsing**: Environment variables are raw strings. Configuration parsers like `koanf` automatically parse string values into native Go types (`int`, `time.Duration`, slices), failing immediately at startup on type mismatches.
2. **Namespace Collision Prevention**: Tools like `env.Provider("BOILERPLATE_", ...)` isolate configuration by reading only variables with a specific prefix and stripping the prefix to match struct tags (e.g., `koanf:"secret_key"`).
3. **Fail-Fast Startup**: Configuration is loaded in `main()` before starting network handlers or database connections. Missing or malformed keys trigger `logger.Fatal()`, stopping the application at boot rather than throwing runtime errors later.
4. **Dependency Injection vs. Global State**: Passing parsed `*Config` structs into constructors avoids scattering environment key lookup throughout the codebase.

### Configuration Pipeline and Package Roles

1. **`godotenv/autoload`**: Reads local `.env` files and populates OS process environment variables via `os.Setenv()` during package initialization (`init()`).
2. **`zerolog`**: Configures structured logging. `zerolog.ConsoleWriter{Out: os.Stderr}` outputs human-readable logs to `stderr` during local execution, ensuring diagnostic logs do not pollute `stdout`.
3. **`koanf`**: Reads environment variables using `koanf.New(".")` and `env.Provider`. The `"."` delimiter specifies nested path structures (`object.subfield`). `k.Unmarshal("", mainConfig)` uses reflection to populate struct fields matching `koanf` tags.
4. **`validator`**: `validator.New().Struct(mainConfig)` inspects struct tags (`validate:"required"`, `validate:"min=1s"`) to validate populated values against defined constraints.
5. **Fallback and Business Rule Validation**: Optional struct fields (like pointers to sub-configs) are populated with default values if `nil`, followed by manual validation methods for rules not captured by tags.

### Dependency Injection vs. Request Context (`c.Get`)

| Mechanism | Purpose | Lifetime | Examples |
| --- | --- | --- | --- |
| **Dependency Injection** | Long-lived application dependencies | Program lifetime | Database pool, logger, config structs, payment clients, repositories. |
| **Request Context (`c.Get`)** | Ephemeral, request-scoped metadata | Single HTTP request | Authenticated `userID`, request ID, trace ID, decoded JWT claims. |

`c.Get("thing")` relies on string keys, returns untyped `any`/`interface{}` values requiring type assertion, and couples domain logic to a web framework context.

### Implementing Dependency Injection in Go

#### Step 1: Define Struct Dependencies

```go
package service

type AuthService struct {
    secretKey string
    db        UserRepository
}

func NewAuthService(secretKey string, db UserRepository) *AuthService {
    return &AuthService{
        secretKey: secretKey,
        db:        db,
    }
}
```

#### Step 2: Inject Service into HTTP Handlers

```go
package handler

type AuthHandler struct {
    authService *service.AuthService
}

func NewAuthHandler(authService *service.AuthService) *AuthHandler {
    return &AuthHandler{authService: authService}
}
```

#### Step 3: Wire Components in `main()`

```go
package main

func main() {
    cfg := config.LoadConfig()
    db := database.New(cfg.Database)
    authService := service.NewAuthService(cfg.Auth.SecretKey, db)
    authHandler := handler.NewAuthHandler(authService)

    router.POST("/login", authHandler.Login)
}
```

#### Testing Advantages

Dependency injection enables passing in-memory struct configurations or mock dependencies directly during unit testing without modifying process environment variables or risking race conditions during parallel test execution (`t.Parallel()`).