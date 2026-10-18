

## UDP Sender Implementation

> [!summary] Key Takeaways
> **UDP is connectionless & fire-and-forget:** No handshake, no delivery guarantees, no ordering — packets are "yeeted" regardless of receiver state.

### Code Structure (`cmd/udpsender/main.go`)

```go
package main

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"os"
)

func main() {
	addr, err := net.ResolveUDPAddr("udp", "localhost:42069")
	if err != nil {
		log.Fatalf("failed to resolve UDP address: %v", err)
	}

	conn, err := net.DialUDP("udp", nil, addr)
	if err != nil {
		log.Fatalf("failed to dial UDP: %v", err)
	}
	defer conn.Close()

	reader := bufio.NewReader(os.Stdin)

	for {
		fmt.Print("> ")

		line, err := reader.ReadString('\n')
		if err != nil {
			log.Printf("error reading input: %v", err)
			continue
		}

		_, err = conn.Write([]byte(line))
		if err != nil {
			log.Printf("error writing to UDP: %v", err)
			continue
		}
	}
}
```

### Execution Flow

| Step | Action                               | Function / Command                               |
| :--- | :----------------------------------- | :----------------------------------------------- |
| 1    | Resolve destination address          | `net.ResolveUDPAddr("udp", "localhost:42069")`   |
| 2    | Create UDP "connection" (local bind) | `net.DialUDP("udp", nil, addr)`                  |
| 3    | Read stdin continuously              | `bufio.NewReader(os.Stdin)` + `ReadString('\n')` |
| 4    | Send datagram immediately            | `conn.Write([]byte(line))`                       |
| 5    | Test with listener                   | `nc -u -l -k 42069` (separate terminal)          |

### UDP vs TCP Behavior

- **No Handshake:** `DialUDP` only binds a local port; no SYN/SYN-ACK/ACK exchange.
- **Receiver Agnostic:** Sender succeeds even if `nc` listener is down (OS may eventually return `ECONNREFUSED` via ICMP, but `Write` typically returns `nil`).
- **No Backpressure:** Packets drop silently if buffers fill; no flow control.
- **Message Boundaries Preserved:** Each `Write` = one datagram (up to ~64KB).

### Quiz: What's True of UDP?

> **Correct:** **It doesn't require a handshake** (Option 3).
> - ❌ Guarantees order → **TCP**
> - ❌ Persistent connection → **TCP**
> - ❌ Confirms delivery → **TCP (ACKs)**

### Related Vault Notes
- [[UDP Assignment]]
- [[TCP Assignment]]
- [[OS Read Assignment]]
