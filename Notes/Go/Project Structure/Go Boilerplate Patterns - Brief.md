# Go Boilerplate Patterns

These patterns exist in the saved project.

## Manual dependency injection

Constructors receive dependencies from their caller.

Examples:

- **server.New(cfg, logger, loggerService)**
- **NewJobService(logger, cfg)**
- **NewAuthMiddleware(server)**

The project does not use a dependency injection framework.

## Other patterns

- Constructor functions: **server.New**, **database.New**, and **email.NewClient**.
- Internal construction: **server.New** creates the database, Redis client, and job service.
- Middleware: **RequireAuth** wraps the next handler.
- Task routing: **ServeMux** maps **TaskWelcome** to its handler.
- Functional options: **MaxRetry**, **Queue**, and **Timeout** configure a task.
- Lifecycle methods: **Start**, **Stop**, and **Shutdown**.
- Global state: **handlers.go** stores **emailClient** in a package variable.

## Missing wiring

- **main.go** does not assemble or start the application.
- No queue producer call exists.
- No caller uses migration or graceful shutdown.
- The email call does not receive the Asynq context.
