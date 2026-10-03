

## Error Creation & Wrapping: `fmt.Errorf` vs `errors.New`

> [!summary] Core Distinction
> **`errors.New`** creates simple, static sentinel errors; **`fmt.Errorf`** enables **error wrapping** (`%w`) for context enrichment and inspection via `errors.Is`/`As`.

### Type Identity
- Both return the **identical concrete type**: `*errors.errorString` (implements `error` interface).
- **Behavior diverges** only when `fmt.Errorf` uses the **`%w` verb**.

### `errors.New` — Sentinel Errors
- **Purpose:** Create **comparable sentinel values** for control flow (e.g., `io.EOF`, `sql.ErrNoRows`).
- **Usage:** `var ErrNotFound = errors.New("not found")`
- **Check:** `errors.Is(err, ErrNotFound)` → **True** (exact pointer match).
- **Wrap:** **Cannot** wrap other errors.

### `fmt.Errorf` — Context & Wrapping
- **Purpose:** Add runtime context (formatting) **and/or** wrap underlying causes.
- **Format verb `%v` / `%s`**: Flattens error → **loses chain** (new `*errorString`).
- **Format verb `%w`**: **Wraps** target error → preserves chain for `errors.Is`/`As`.

```go
// Simple formatting (NO wrap)
err = fmt.Errorf("connect failed: %v", origErr) 

// Explicit Wrap (PRESERVES chain)
err = fmt.Errorf("connect failed: %w", origErr) 
```

### Wrapping Mechanics (`%w`)
- **Single Wrap:** `fmt.Errorf("ctx: %w", err)` → `err` accessible via `errors.Unwrap()`.
- **Multiple Wrap (Go 1.20+):** `fmt.Errorf("ctx: %w; %w", err1, err2)` → Returns wrapper implementing `Unwrap() []error`.
- **Inspection:**
  - `errors.Is(err, target)` → Walks chain, matches **identity** (sentinels).
  - `errors.As(err, &target)` → Walks chain, matches **type** (custom error structs).

### Decision Matrix

| Scenario | Function | Verb | Chain Preserved? |
| :--- | :--- | :--- | :--- |
| Static sentinel definition | `errors.New` | N/A | N/A |
| Add context, **discard** cause | `fmt.Errorf` | `%v` / `%s` | **No** |
| Add context, **keep** cause | `fmt.Errorf` | `%w` | **Yes** |
| Join multiple causes (1.20+) | `fmt.Errorf` | `%w` (multi) | **Yes** (slice) |

### Best Practice
- **Define** sentinels with `errors.New` in package roots.
- **Wrap** upstream errors at call boundaries with `fmt.Errorf("op failed: %w", err)`.
- **Inspect** using `errors.Is` (sentinels) or `errors.As` (typed details) — **never** string match `err.Error()`.

> [[Error Handling]]

## RESTful API Fundamentals

> [!summary] Core Insight
> **REST** standardizes HTTP APIs around **resources** (nouns) and **stateless** interactions, enabling independent client/server evolution.

### Core Principles

- **Resource-Oriented**: URLs identify **resources** (e.g., `/projects`, `/users`), not actions.
- **Stateless**: Server retains no client context between requests; each request contains all info needed.
- **Language-Agnostic**: Client/server implementations decoupled via standard HTTP semantics.
- **Standard Methods**: `GET` (read), `POST` (create), `PUT` (update), `DELETE` (remove) map to CRUD.

### URL Structure (Jello API Example)

| Segment | Example | Purpose |
| :--- | :--- | :--- |
| **Version** | `v1` | API versioning |
| **Context** | `courses_rest_api/learn-http` | Namespace/course identifier |
| **Resource** | `projects` \| `users` \| `issues` | Target resource collection |

```text
https://api.boot.dev/v1/courses_rest_api/learn-http/projects
                         │                    │
                         │                    └── Resource
                         └── Course/Context
```

### Key Distinctions

- **REST != HTTP**: Not all HTTP APIs are RESTful; REST imposes architectural constraints.
- **Stateless != No State**: Server *stores* resource state (DB), but doesn't track *client session state*.
- **Paths = Nouns**: `/issues/123` ✓ | `/getIssue/123` ✗
