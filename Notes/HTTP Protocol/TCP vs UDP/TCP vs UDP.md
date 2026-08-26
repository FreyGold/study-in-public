

## UDP & TCP Network Setup

> [!summary] Key Takeaway
> **Resolve then Dial:** UDP requires explicit address resolution (`ResolveUDPAddr`) before socket creation (`DialUDP`); TCP abstracts this via `Dial`/`Listen` but offers low-level `DialTCP` for granular control.

### UDP Flow
- **ResolveUDPAddr** → Parses `host:port` into `*net.UDPAddr` (performs DNS lookup if domain used).
  - `network`: `"udp"`, `"udp4"`, or `"udp6"`
  - `address`: `"host:port"` (e.g., `"localhost:42069"`, `":8080"`)
- **DialUDP** → Creates `*net.UDPConn` configured for remote/local endpoints (connectionless, no handshake).
  - `network`: matches address type (`"udp"`, `"udp4"`, `"udp6"`)
  - `laddr`: Local `*net.UDPAddr` (nil = OS assigns ephemeral port)
  - `raddr`: Remote `*net.UDPAddr` (**required**)

### TCP Setup

| Role | Function | Signature | Use Case |
|------|----------|-----------|----------|
| Client | `net.Dial` | `Dial(network, address string)` | High-level TCP handshake; `network` = `"tcp"`, `"tcp4"`, `"tcp6"` |
| Server | `net.Listen` | `Listen(network, address string)` | Binds listener; `address` = `":port"` or `"host:port"` |
| Low-level Client | `net.DialTCP` | `DialTCP(network string, laddr, raddr *net.TCPAddr)` | Explicit `*net.TCPAddr` control (mirrors `DialUDP` pattern) |

> [!tip] Related Concepts
> - See [[TCP vs UDP]] for protocol trade-offs
> - See [[Go Starter]] for project scaffolding context

