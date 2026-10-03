## Unified CLI Command Signature

**Define callback with variadic args:**

```go
type CliCommand struct {
    Name        string
    Description string
    Callback    func(*Config, ...string) error
}
```

**Implement handlers:**

```go
func commandExit(cfg *config.Config, args ...string) error {
    os.Exit(0); return nil
}

func commandExplore(cfg *config.Config, args ...string) error {
    if len(args) == 0 { return errors.New("area name required") }
    area := args[0]
    // fetch & print
    return nil
}
```

**Invoke from REPL:**

```go
words := strings.Fields(input)
cmd, ok := commands[words[0]]
if !ok { return }
args := words[1:]
err := cmd.Callback(cfg, args...)
```

- **Variadic `...string`** accepts zero or more arguments; callers can pass slice with `args...`.
- **Single map type** `map[string]CliCommand` holds all commands regardless of arity.
- **Forward-compatible**: existing commands ignore `args`; new commands consume as needed.