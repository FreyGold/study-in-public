## Internal Packages and Shared Config

**Create internal package:**

```bash
mkdir -p internal/pokeapi
mv pokeapi.go internal/pokeapi/
# Update package declaration
package pokeapi
```

**Import using module path** (from `go.mod`):

```go
import "github.com/FrexGeld/pokedex/internal/pokeapi"
```

**Cannot import from `package main`**. Move shared types (`Config`, `CliCommand`) to a package both `main` and `internal/*` can import:

- **Option 1**: Place in `internal/pokeapi` (if tightly coupled).
- **Option 2**: Create `internal/config` for broader sharing.

```go
// internal/config/config.go
package config

type Config struct {
    Commands map[string]CliCommand
    Next     *string
    Previous *string
}
```

- **Export fields** (capitalize) for cross-package access.
- **Fix module typo** in imports (`FrexGeld` not `FreyGold`).
- **Prefix types** with package name: `config.Config`, `config.CliCommand`.