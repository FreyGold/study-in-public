---
title: "Go: Errorf vs errors.New"
aliases: ["Go Error Creation"]
tags:
  - notes/golang
  - notes/error-handling
  - status/seedling
created: "2026-08-19"
summary: "Use errors.New for static sentinel errors; use fmt.Errorf with %w for wrapping context and enabling error inspection via errors.Is/As."
---

> [!summary] Key Takeaways
> **Core Insight:** `errors.New` creates simple, static sentinel errors for direct comparison; `fmt.Errorf` with `%w` wraps errors to preserve the chain for programmatic inspection (`errors.Is`/`errors.As`).

- **Type:** Both return the `error` interface (`interface { Error() string }`).
- **errors.New (Static Sentinels)**
  - **Use Case:** Fixed, unchanging error values (e.g., `ErrNotFound`, `io.EOF`).
  - **Behavior:** Returns a new unique error instance every call; **not comparable** across calls unless assigned to a variable.
  - **Wrapping:** **Cannot** wrap other errors (no `%w` support).
  - **Inspection:** Only supports direct equality check (`err == ErrNotFound`).

- **fmt.Errorf (Dynamic & Wrapping)**
  - **Use Case:** Adding runtime context, formatting messages, **wrapping** underlying causes.
  - **Verb `%w`**: Wraps target error, enabling `errors.Is`/`errors.As` traversal.
  - **Verb `%v` / `%s`**: Formats error **without** wrapping (loses chain).
  - **Multiple Wraps:** Supports wrapping multiple errors (`%w` multiple times) -> returns `interface{ Unwrap() []error }`.

- **Decision Matrix**

  | Scenario | Function | Verb |
  | :--- | :--- | :--- |
  | Define package-level sentinel | `errors.New` | N/A |
  | Simple static message (no context) | `errors.New` | N/A |
  | Add context / format string | `fmt.Errorf` | `%v` / `%s` |
  | **Preserve cause for `errors.Is`** | `fmt.Errorf` | **`%w`** |

- **Code Patterns**
  ```go
  // Sentinel (compare via errors.Is or ==)
  var ErrNotFound = errors.New("not found")

  // Wrap for inspection chain
  func ReadFile(path string) error {
      data, err := os.ReadFile(path)
      if err != nil {
          return fmt.Errorf("read config %s: %w", path, err) // %w preserves err
      }
      return nil
  }

  // Check chain
  if errors.Is(err, ErrNotFound) { ... }      // True if ErrNotFound in chain
  var pathErr *fs.PathError
  if errors.As(err, &pathErr) { ... }          // True if *fs.PathError in chain
  ```