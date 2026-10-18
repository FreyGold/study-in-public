

## TCP Server Implementation

> [!summary] Key Takeaways
> **Core Insight:** Implements a concurrent TCP server on port `42069` using Go's `net` package, leveraging `getLinesChannel` (from [[Channels]]) to stream lines from accepted connections to stdout for `tee` capture.

### Core Implementation
```go
package main

import (
	"fmt"
	"log"
	"net"
)

func main() {
	listener, err := net.Listen("tcp", ":42069")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	defer listener.Close()

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Fatalf("failed to accept connection: %v", err)
		}

		fmt.Println("Accepted connection")

		lines := getLinesChannel(conn)
		for line := range lines {
			fmt.Println(line)
		}

		fmt.Println("Connection closed")
	}
}
```

### Key Concepts
- **net.Listen:** Binds to TCP port `:42069`; returns `net.Listener`.
- **listener.Accept():** Blocks until incoming connection; returns `net.Conn`.
- **getLinesChannel(conn):** Reads `conn` line-by-line into a channel (see [[Channels]]).
- **fmt.Println vs log.Println:** `fmt` writes to **stdout** (captured by `tee`); `log` writes to **stderr** (ignored by `tee`).
- **Graceful Shutdown:** `defer listener.Close()` ensures port release on exit (Ctrl+C).

### Testing & Verification
| Step | Command | Purpose |
| :--- | :--- | :--- |
| **Run Server** | `go run . \| tee /tmp/tcp.txt` | Start server, pipe stdout to file & console |
| **Send Data** | `printf "Do you have what it takes to be an engineer at TheStartup™?\r\n" \| nc -w 1 127.0.0.1 42069` | Test connection via netcat (OpenBSD variant) |
| **Verify Output** | `cat /tmp/tcp.txt` | Confirm message logged correctly |

### Bootdev CLI Workflow
- **Run Locally:** `bootdev run`
- **Submit Solution:** `bootdev run -s`

### Context
Part of [[TCP Assignment]]: Replaces file I/O with network I/O to simulate HTTP request handling foundation.
