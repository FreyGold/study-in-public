## Core Steps

- **Edit go.mod**: Change the `module` directive to the new path.
  ```go
  module github.com/newname/myproject
  go 1.25
  ```

- **Rewrite imports**: Update every import in the codebase to match the new module path.
  ```go
  import "github.com/newname/myproject/internal/foo"
  ```

- **One-liner**: From project root:
  ```bash
  go mod edit -module github.com/newname/myproject
  go mod tidy
  ```

## Notes

- Go has no separate "project name"; the `module` line **is** the identity.
- For unpublished local projects, a bare name (`module myproject`) works, but using the future repo path (`github.com/user/project`) avoids future rewrites.
- Run `go mod tidy` after the change to sync `go.sum` and download any missing deps.