---
title: "HTTP Server Implementation Guide"
aliases: ["Go HTTP Server", "Custom HTTP Server"]
tags:
  - notes/http-protocol
  - tech/go
  - status/seedling
created: "2026-08-23"
summary: "A comprehensive guide to building a production-grade HTTP/1.1 server in Go from scratch, covering listener management, connection handling, graceful shutdown, and hardcoded response generation."
---

> [!example] Visual Architecture Diagram
> **Excalidraw Overview:** [[Excalidrawings/Notes/HTTP Protocol/HTTP Server Implementation Guide.excalidraw|HTTP Server Implementation Guide Architecture]]

> [!summary] Executive Summary
> This note details the implementation of a custom **HTTP/1.1 server** in Go, bridging the gap between raw TCP listeners (covered in `[[TCP]]`) and the request parsing logic (covered in `[[HTTP Request Stream Parsing]]` and `[[HTTP Request Line Parser]]`). It follows the **Bun.js** / **Go `http.Server`** pattern: a `Serve` function that spawns a background listener, a `listen` loop accepting connections, and a `handle` function writing a valid HTTP response. Critical patterns include **atomic state tracking** for safe shutdown and **signal handling** for graceful termination.

---

## 1. Architecture & Design Philosophy

The server implementation adheres to a **minimalist, stdlib-only** approach. Unlike the standard library's `http.Server` which decouples routing via `Handler` interfaces, this version **hardcodes the response logic** inside `handle()` to isolate the transport layer mechanics.

> [!info] Design Comparison
> | Feature | **Bun `serve`** | **Go `http.Server`** | **This Implementation** |
> | :--- | :--- | :--- | :--- |
> **Entry Point** | `Bun.serve({ fetch })` | `server.ListenAndServe()` | `server.Serve(port)` |
> **Concurrency** | Automatic (Worker threads) | Automatic (Goroutines per conn) | Explicit `go s.listen()` + `go s.handle(conn)` |
> **Request Abstraction** | `Request` object (Web Standard) | `*http.Request` | Raw `net.Conn` + Manual Parsing |
> **Response Abstraction** | `Response` object | `http.ResponseWriter` | Manual `conn.Write([]byte)` |
> **Shutdown** | `server.stop()` | `server.Shutdown(ctx)` | `server.Close()` + Signal Channel |

```mermaid
flowchart TD
    subgraph Main["cmd/httpserver/main.go"]
        MainStart["main("")"] --> ServeCall["server.Serve("42069")"]
        ServeCall --> SigSetup["signal.Notify("sigChan, SIGINT, SIGTERM")"]
        SigSetup --> Block["<-sigChan("Block")"]
        Block --> CloseCall["server.Close("")"]
        CloseCall --> Exit["log.Println("'Stopped'")"]
    end

    subgraph ServerPkg["internal/server/server.go"]
        ServeCall --> ServeFunc["Serve("port int") (*Server, error)"]
        ServeFunc --> Listener["net.Listen("'tcp', addr")"]
        Listener --> ServerStruct["return &Server{"listener, atomic.Bool"}"]
        ServerStruct --> GoListen["go s.listen("")"]
    end

    subgraph ListenLoop["listen("")"]
        GoListen --> LoopStart["for !s.closed.Load("")"]
        LoopStart --> Accept["listener.Accept("")"]
        Accept --> ErrCheck{"err != nil?"}
        ErrCheck -->|"Yes("Closed")"| Ignore["Ignore & Continue"]
        ErrCheck -->|"No"| SpawnHandle["go s.handle("conn")"]
        Ignore --> LoopStart
        SpawnHandle --> LoopStart
    end

    subgraph HandleConn["handle("conn net.Conn")"]
        SpawnHandle --> DeferClose["defer conn.Close("")"]
        DeferClose --> WriteResp["conn.Write("ResponseBytes")"]
        WriteResp --> Done["Return"]
    end
```

---

## 2. Project Structure

```text
project-root/
├── cmd/
│   └── httpserver/
│       └── main.go          # Entry point, signal handling, server lifecycle
└── internal/
    └── server/
        └── server.go        # Server struct, Serve, Close, listen, handle
```

---

## 3. Implementation Deep Dive

### 3.1 Entry Point: `cmd/httpserver/main.go`

This file orchestrates the **process lifecycle**. It does not know *how* the server works, only *that* it implements `Serve` and `Close`.

```go
package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"your-module/internal/server" // Adjust import path
)

const port = 42069

func main() {
	// 1. Start Server (Non-blocking)
	srv, err := server.Serve(port)
	if err != nil {
		log.Fatalf("Error starting server: %v", err)
	}
	defer srv.Close() // Guaranteed cleanup on main exit

	log.Println("Server started on port", port)

	// 2. Graceful Shutdown Signal Handling
	sigChan := make(chan os.Signal, 1)
	// Buffer size 1 ensures we don't miss the signal if Close() takes time
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	// 3. Block Until Signal Received
	<-sigChan 
	log.Println("Server gracefully stopped")
}
```

> [!tip] **Why `defer srv.Close()`?**
> If `main` returns (e.g., via `log.Fatal` elsewhere or panic), `defer` ensures the TCP listener socket is closed, preventing `TIME_WAIT` port binding issues on rapid restarts.

---

### 3.2 Server Package: `internal/server/server.go`

#### 3.2.1 State Definition

```go
package server

import (
	"net"
	"sync/atomic"
)

// Server holds the listener and an atomic flag for thread-safe shutdown detection.
type Server struct {
	listener net.Listener
	closed   atomic.Bool // true after Close() is called
}
```

> [!info] **`atomic.Bool` vs `sync.Mutex`**
> - **`atomic.Bool`**: Lock-free, optimal for a **single boolean flag** read frequently (every `Accept` loop iteration) and written once (on `Close`).
> - **`sync.Mutex`**: Overkill for a simple flag; introduces contention risk under high connection load.

#### 3.2.2 Constructor & Listener Bootstrap: `Serve`

```go
func Serve(port int) (*Server, error) {
	addr := ":" + strconv.Itoa(port) // e.g., ":42069"
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		return nil, err
	}

	s := &Server{
		listener: listener,
	}
	// closed defaults to false (zero value)

	// Start the accept loop in a background goroutine
	go s.listen()

	return s, nil
}
```

#### 3.2.3 The Accept Loop: `listen`

This is the **hot path**. It runs until `Close()` flips the atomic flag.

```go
func (s *Server) listen() {
	for {
		// 1. Check shutdown flag BEFORE blocking on Accept
		if s.closed.Load() {
			return
		}

		// 2. Block waiting for new connection
		conn, err := s.listener.Accept()
		if err != nil {
			// 3. Handle Listener Closure
			if s.closed.Load() {
				// Expected error: listener closed by Close()
				return
			}
			// Unexpected error (e.g., EMFILE, ECONNABORTED)
			// Log and continue to avoid tight loop on transient errors
			log.Printf("Accept error: %v", err)
			continue
		}

		// 4. Handle Connection Concurrently
		go s.handle(conn)
	}
}
```

> [!warning] **Pitfall: `Accept` on Closed Listener**
> Calling `listener.Close()` unblocks `Accept` immediately, returning an error (`use of closed network connection`). **Always check `s.closed.Load()` *after* an `Accept` error** to distinguish "server shutting down" from "network glitch".

#### 3.2.4 Connection Handler: `handle`

Writes a **statically defined, valid HTTP/1.1 response**.

```go
func (s *Server) handle(conn net.Conn) {
	defer conn.Close() // Ensure socket cleanup

	// Pre-computed Response (avoids allocation per request)
	// Body: "Hello World!\n" (13 bytes)
	const response = "HTTP/1.1 200 OK\r\n" +
		"Content-Type: text/plain\r\n" +
		"Content-Length: 13\r\n" +
		"\r\n" +
		"Hello World!\n"

	// Write entire response. In production, use bufio.Writer for large bodies.
	_, err := conn.Write([]byte(response))
	if err != nil {
		log.Printf("Write error: %v", err)
	}
	// Connection closes via defer
}
```

> [!tip] **HTTP/1.1 Formatting Rules**
> 1. **Status Line**: `HTTP/1.1 200 OK\r\n` (Version, Code, Reason Phrase).
> 2. **Headers**: `Key: Value\r\n` (Case-insensitive keys, terminated by `\r\n`).
> 3. **Blank Line**: `\r\n` (Mandatory separator between headers and body).
> 4. **Body**: Exact `Content-Length` bytes. **No chunked encoding** here.

#### 3.2.5 Graceful Shutdown: `Close`

```go
func (s *Server) Close() error {
	// 1. Set Flag Atomically (Signals listen loop to exit)
	s.closed.Store(true)

	// 2. Close Listener (Unblocks Accept())
	// Returns error if already closed, which is fine.
	return s.listener.Close()
}
```

> [!info] **Shutdown Sequence**
> 1. `main` receives `SIGINT` -> calls `srv.Close()`.
> 2. `Close()` sets `closed=true` -> calls `listener.Close()`.
> 3. `listener.Close()` causes `Accept()` in `listen()` to return error.
> 4. `listen()` sees `closed=true` -> returns, ending goroutine.
> 5. **In-flight `handle()` goroutines continue** to completion (drain).
> 6. `main` logs "Stopped" and exits.

---

## 4. HTTP Response Construction Details

The hardcoded response string is a valid **HTTP/1.1 200 OK** payload.

| Component | Value | Notes |
| :--- | :--- | :--- |
| **Protocol** | `HTTP/1.1` | Matches `[[RFCs]]` (RFC 9112) |
| **Status Code** | `200` | Success |
| **Reason Phrase** | `OK` | Human readable, ignored by parsers |
| **Content-Type** | `text/plain` | No charset specified (defaults to ISO-8859-1) |
| **Content-Length** | `13` | **Critical**: Must match body byte count exactly |
| **Body** | `Hello World!\n` | 12 chars + 1 newline = 13 bytes |

> [!warning] **Content-Length Mismatch**
> If `Content-Length` > actual body bytes: Client hangs waiting for data.
> If `Content-Length` < actual body bytes: Client truncates, next read corrupts pipelined requests.

---

## 5. Testing & Verification

### 5.1 Manual `curl` Test
```bash
# Run server in background
go run cmd/httpserver/main.go &

# Test
curl -v http://localhost:42069/
# Expected: 200 OK, Content-Length: 13, Body: "Hello World!"

# Shutdown
kill %1 # Sends SIGTERM to background job
```

### 5.2 CLI Test Suite Expectations (Boot.dev Style)
The assignment implies automated tests verifying:
1.  **Port Binding**: Server starts on 42069.
2.  **Concurrency**: Multiple simultaneous `curl` requests succeed.
3.  **Response Validity**: Strict HTTP/1.1 format compliance (CRLF, Headers, Length).
4.  **Graceful Shutdown**: `SIGINT`/`SIGTERM` triggers `Close()` and exits cleanly.

---

## 6. Evolutionary Roadmap (Future Steps)

| Step | Feature | Implementation Hint |
| :--- | :--- | :--- |
| **Current** | Hardcoded Response | `handle()` writes static bytes. |
| **Next** | **Request Parsing** | Integrate `[[HTTP Request Line Parser]]` + `[[HTTP Request Stream Parsing]]` inside `handle()`. |
| **Next** | **Handler Interface** | Add `Handler func(*Request) *Response` field to `Server` struct; `Serve` accepts it. |
| **Next** | **Routing** | Implement `ServeMux` pattern (path -> handler map). |
| **Production** | **Timeouts** | Set `listener.(*net.TCPListener).SetDeadline` / `conn.SetReadDeadline`. |
| **Production** | **TLS** | Use `tls.NewListener` with `net.Listen`. |

---

## 7. Related Vault Notes

- **Protocol Foundation**: `[[HTTP/1.1 Fundamentals]]`, `[[RFCs]]`
- **Parsing Prerequisites**: `[[HTTP Request Line Parser]]`, `[[HTTP Request Stream Parsing]]`
- **Transport Layer**: `[[TCP]]`, `[[TCP Assignment]]` (Concurrent listener pattern)
- **Concurrency Primitives**: `[[Channels]]` (Signal channel pattern), `[[OS Read Assignment]]` (Goroutine + Channel streaming)
- **Client Perspective**: `[[Requests]]`, `[[Error Handling]]` (for client-side interaction patterns)