

## Go Project Initialization

> [!summary] Key Takeaways
> **Core Insight:** Initialize a module with `go mod init`, define the entry point in `main.go`, and organize logic into separate packages for clean architecture.

### Module Setup
- **`go mod init <module-path>`**: Creates `go.mod` defining module path (import prefix) and Go version.
  - Example: `go mod init github.com/user/project`
- **`go.mod`**: Tracks dependencies; commit this file to version control.

### Entry Point
- **`main.go`**: Required `package main` + `func main()`.
  - Place in repo root or `cmd/<app-name>/` for multi-app repos.
  - **Run:** `go run main.go` or `go run .`

### Package Structure
| Pattern | Layout | Use Case |
| :--- | :--- | :--- |
| **Flat** | `main.go`, `utils.go` | Tiny CLIs, scripts |
| **Standard** | `internal/`, `pkg/`, `cmd/` | Production services, libraries |
| **Domain-Driven** | `internal/{user,order}/` | Large apps with bounded contexts |

- **`internal/`**: Code private to this module (enforced by compiler).
- **`pkg/`**: Library code safe for external import.
- **`cmd/<name>/main.go`**: Entry points for each binary.

### Common Commands
- **`go mod tidy`**: Sync `go.mod`/`go.sum` with actual imports.
- **`go build ./...`**: Compile all packages, catch build errors early.
- **`go test ./...`**: Run tests across all packages.


## Imports

> [!summary] Key Takeaways
> **Core Insight:** Go imports declare package dependencies; use **standard library** first, then **third-party**, then **local** packages, grouped and separated by blank lines for readability.

## Import Syntax & Organization

- **Standard Library**: `import "fmt"` (no domain prefix).
- **Third-Party**: `import "github.com/gin-gonic/gin"` (full module path).
- **Local Packages**: `import "myproject/internal/config"` (module-relative path).
- **Grouping**: Separate groups with a blank line; `goimports` / `gofmt` enforce this automatically.

```go
import (
	"context"           // Stdlib
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin" // Third-party

	"myproject/internal/auth"  // Local
	"myproject/pkg/logger"
)
```

## Advanced Patterns

- **Aliasing**: Resolve name collisions (`import mylib "github.com/other/lib"`).
- **Blank Identifier (`_`)**: Trigger `init()` side-effects only (`import _ "github.com/lib/pq"`).
- **Dot Import (`.`)**: **Avoid.** Pollutes namespace (`import . "fmt"` -> `Println()` vs `fmt.Println()`).
- **Vendoring**: `go mod vendor` copies dependencies to `vendor/` for offline/reproducible builds.

## Best Practices

- **Minimize Scope**: Import only what you use; linters (`staticcheck`, `golangci-lint`) flag unused imports.
- **Module Path**: Match `go.mod` module declaration (`module github.com/user/repo`).
- **Internal Packages**: Use `internal/` directories to enforce encapsulation (unimportable outside parent module).
