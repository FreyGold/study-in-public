### What Struct Tags Are

In Go, a struct tag is string metadata attached to a struct field (enclosed in backticks). It does nothing by itself during standard execution; instead, external packages read it at runtime using reflection (`reflect`) to determine how to handle that field.

### When to Use Them

Use struct tags whenever you need to map, serialize, or validate struct fields with external data:

- Serialization / Deserialization: Mapping field names to JSON, YAML, XML, or database columns (e.g., `json:"user_id"`, `db:"user_id"`).
- Configuration Parsers: Mapping environment variables or config keys.
- Validation: Enforcing rules like required values, email formats, or min/max lengths (like `validate:"required"` using libraries like `go-playground/validator`).
- Form / URL Parsing: Binding query parameters or request forms (e.g., `form:"page"`).

### How to Use Them

#### 1. Syntax Convention

Tags follow a space-separated `key:"value"` format inside backticks:

```go
type User struct {
    ID    int    `json:"id" db:"user_id"`
    Email string `json:"email" validate:"required,email"`
    Role  string `json:"-"` // "-" tells encoders to ignore this field
}
```

Rules:
- No space around the colon: `key:"value"` (not `key: "value"`).
- Multiple options are typically comma-separated within the quotes: `validate:"required,min=3"`.
- Separate distinct tags with spaces: ``json:"name" validate:"required"``.

#### 2. How Libraries Read Them

Under the hood, libraries use the `reflect` package to read these values:

```go
package main

import (
    "fmt"
    "reflect"
)

type Config struct {
    Env string `koanf:"env" validate:"required"`
}

func main() {
    c := Config{}
    field, _ := reflect.TypeOf(c).FieldByName("Env")

    tag := field.Tag
    fmt.Println("koanf:", tag.Get("koanf"))       // env
    fmt.Println("validate:", tag.Get("validate")) // required
}
```

### Enforcement Mechanics

Struct tags do not enforce any rules on their own, and Go will never return an error automatically if a tagged field is missing or empty. They are inert metadata without code actively inspecting them via `reflect` or code generation.

To make tags like `validate:"required"` work, you must pass the struct instance into a validation engine (such as `go-playground/validator`):

```go
package main

import (
	"fmt"
	"github.com/go-playground/validator/v10"
)

type Primary struct {
	Env string `koanf:"env" validate:"required"`
}

func main() {
	validate := validator.New()

	p := Primary{} // Env is empty ("")

	err := validate.Struct(p)
	if err != nil {
		fmt.Println("Validation failed:", err)
	}
}
```

### Rule Enforcement Without Reflection

1. **Manual Validation Methods**: Write an explicit method on the struct to avoid reflection overhead:

```go
func (p Primary) Validate() error {
	if p.Env == "" {
		return fmt.Errorf("env is required")
	}
	return nil
}
```

2. **Code Generation (Compile-Time)**: Tools inspect code/definitions before compilation and generate static Go validation code, avoiding runtime reflection.