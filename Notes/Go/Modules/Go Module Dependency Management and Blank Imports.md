t### Removing Packages via CLI

To remove an unused package from your `go.mod` file via the CLI:

1. Remove all imports referencing the package from your `.go` source files.
2. Run `go mod tidy`:

```bash
go mod tidy
```

`go mod tidy` scans your source tree, adds missing module requirements, and automatically prunes any dependencies that are no longer imported.

### Explicitly Dropping Packages via `go get`

To explicitly drop a specific module requirement directly from the command line:

```bash
go get example.com/package@none
```

Setting the version to `@none` removes the requirement directive from `go.mod` (as long as no source files are actively importing it). Run `go mod tidy` afterward to clean up any orphaned indirect dependencies.

### Why `go mod tidy` Drops Packages

In Go:
- `go get package` downloads the package and adds it to `go.mod`.
- When you run `go mod tidy`, Go checks all `.go` files in your project.
- If no file imports the package, or if compilation fails with an "imported and not used" error because an import is not referenced in the file, `go mod tidy` considers it an unreferenced dependency and removes it from `go.mod`.

### Retaining Imports During Development

#### Option 1: Blank Identifier `_`
Prefix the import with an underscore so Go permits keeping it without actively calling it:

```go
import (
    "os"

    _ "github.com/knadh/koanf/v2"
    _ "github.com/rs/zerolog"
)
```

#### Option 2: Reference in Code
Call or declare an instance inside the package:

```go
package config

import (
    "github.com/knadh/koanf/v2"
    "github.com/rs/zerolog"
)

var (
    _ = koanf.New(".")
    _ = zerolog.Logger{}
)
```

### Purpose of Blank Identifier (`_`)

The blank identifier serves two distinct purposes:

1. **In Code Drafting (Temporary)**: Using `_ = someVar` or `var _ = package.Func()` prevents compiler errors for unused variables during development.
2. **In Imports (Side Effects)**: Importing `_ "github.com/joho/godotenv/autoload"` informs Go that no exported functions or types are directly used, but its `init()` function must run at boot to load `.env` key-values into `os.Setenv()`.