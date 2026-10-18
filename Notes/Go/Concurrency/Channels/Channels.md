

> [!summary] Go Channels Cheat Sheet
> **Core Insight:** Channels are typed conduits for safe communication and synchronization between goroutines; **don't communicate by sharing memory, share memory by communicating.**

## Declaration & Initialization
- **Syntax:** `ch := make(chan int)` (unbuffered) | `ch := make(chan int, 10)` (buffered)
- **Zero Value:** `nil` channel blocks forever on send/receive; panic on close.
- **Directionality:** `chan<- int` (send-only), `<-chan int` (receive-only) — enforce at compile time.

## Core Operations
| Operation | Syntax | Blocks When... |
| :--- | :--- | :--- |
| **Send** | `ch <- val` | Buffer full (or no receiver for unbuffered) |
| **Receive** | `val := <-ch` | Buffer empty (or no sender for unbuffered) |
| **Close** | `close(ch)` | N/A (panics if closed twice or closed on receive-only) |
| **Check Closed** | `val, ok := <-ch` | N/A (`ok == false` if closed & empty) |

## Patterns & Idioms
- **Range over Channel:** `for v := range ch { ... }` — exits automatically on `close(ch)`.
- **Select Statement:** Multiplex multiple channels; `default` case makes it non-blocking.
- **Worker Pool:** Fan-out via shared input channel; fan-in via `sync.WaitGroup` + single output channel.
- **Pipeline:** Chain stages (`Stage1 -> chan -> Stage2 -> chan -> Stage3`); close downstream when upstream closes.
- **Timeout/Cancellation:** `select { case <-ch: ... case <-time.After(1s): ... }` or `case <-ctx.Done():`.
- **Semaphore (Rate Limiting):** Buffered channel of struct{}: `sem := make(chan struct{}, N)`; acquire `<-sem`, release `sem<-struct{}{}`.

## Critical Rules (Panic Prevention)
- **Never close** a channel from the **receiver** side.
- **Never close** a **closed** channel.
- **Never send** on a **closed** channel.
- **Only the sender** (or owner) should close the channel.
- **Unbuffered:** Send/Receive synchronize (rendezvous) — both block until the other is ready.
- **Buffered:** Send blocks only when full; Receive blocks only when empty.

## Common Pitfalls
- **Goroutine Leak:** Sender blocks on unbuffered/full channel but receiver stopped listening.
- **Deadlock:** `select {}` with no cases or all channels nil/blocked forever.
- **Race on Close:** Closing channel while other goroutines might still send.

## [[Channels]] Integration
- See [[Channels]] for deeper patterns (pub/sub, errgroup, context propagation).
