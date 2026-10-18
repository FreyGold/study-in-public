

## File Chunk Reading Pattern

> [!summary] Key Takeaway
> **Stream large files efficiently** by reading fixed-size byte chunks (e.g., 8 bytes) in a loop until `io.EOF` signals completion.

### Core Implementation

```go
package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	// 1. Open file for reading
	f, err := os.Open("messages.txt")
	if err != nil {
		panic(err) // Handle [[Error Handling]]
	}
	defer f.Close()

	// 2. Define chunk buffer (8 bytes)
	buf := make([]byte, 8)

	// 3. Loop until EOF
	for {
		n, err := f.Read(buf)
		if err == io.EOF {
			break // Clean exit condition
		}
		if err != nil {
			panic(err)
		}

		// 4. Process exact bytes read (n <= 8)
		fmt.Printf("read: %s\n", string(buf[:n]))
	}
}
```

### Critical Details

- **`os.Open`**: Returns `*os.File` implementing `io.Reader`. See [[OS]].
- **`Read(buf)`**: Returns `(n int, err error)`.
  - **`n`**: Bytes actually read (0 to `len(buf)`).
  - **`err == io.EOF`**: **Expected termination signal**, not an error to log.
  - **`buf[:n]`**: Slice to **exact valid data**; avoids printing garbage from buffer reuse.
- **Buffer Reuse**: Single `make([]byte, 8)` allocation outside loop = **zero alloc/op** in hot path.

### Common Pitfalls

| Mistake                   | Consequence                                                  | Fix                                            |
| :------------------------ | :----------------------------------------------------------- | :--------------------------------------------- |
| `fmt.Print(string(buf))`  | Prints stale bytes from previous read on final partial chunk | Use `buf[:n]`                                  |
| `if err != nil { break }` | Treats `io.EOF` as generic error, loses last chunk           | Check `err == io.EOF` **after** processing `n` |
| No `defer f.Close()`      | File descriptor leak                                         | Always defer close immediately after open      |
