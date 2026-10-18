---
title: "HTTP/1.1 Fundamentals"
aliases: ["HTTP Basics"]
tags:
  - notes/networking
  - notes/http
  - status/seedling
created: "2026-08-21"
summary: "HTTP/1.1 is a text-based protocol over TCP using a strict message format: start-line, headers, blank line, optional body."
---

> [!summary] Key Takeaways
> **Core Insight:** HTTP/1.1 layers a structured text format (RFC 9112) on top of **TCP**, leveraging TCP's ordered, reliable stream to reconstruct messages split across packets.

## Core Concepts
- **Protocol Stack:** HTTP/1.1 = Text-based application layer **+** [[TCP]] transport layer.
- **Reliability:** TCP handles segmentation/reassembly; HTTP assumes in-order, complete byte stream.
- **Format:** Strict `CRLF` (`\r\n`) delimited structure (Windows-style newlines).
- **Mnemonic:** `\r\n` = "**R**egistered **N**urse" (Carriage Return + Line Feed).

## HTTP Message Structure (RFC 9112 §2.1)

| Part | Example | Description |
| :--- | :--- | :--- |
| `start-line CRLF` | `POST /users/primeagen HTTP/1.1` | Request line (method, target, version) or Status line (version, code, phrase). |
| `*( field-line CRLF )` | `Host: google.com` | Zero or more **Header** lines (Key: Value pairs). |
| `CRLF` | *(empty line)* | **Blank line** separating headers from body. |
| `[ message-body ]` | `{"name": "TheHTTPagen"}` | Optional payload (JSON, HTML, binary, etc.). |

> [!note] Requests & Responses
> Both follow this identical envelope format; only the `start-line` and specific header semantics differ.

## Assignment: Capture Raw HTTP Request
**Goal:** Inspect the raw bytes sent by `curl` to your TCP listener.

1. **Start Listener & Capture Output:**
   ```bash
   go run ./cmd/tcplistener | tee /tmp/rawget.http
   ```
2. **Send Request (separate terminal):**
   ```bash
   curl http://localhost:42069/coffee
   ```
   *Note: `curl` hangs because the listener accepts but doesn't respond.*
3. **Inspect:**
   - Kill both processes (`Ctrl+C`).
   - Open `/tmp/rawget.http` to analyze the raw request structure (start-line, headers, blank line, no body for GET).
4. **Submit:** Run CLI tests.

## References
- [[TCP]] - Transport layer guarantees leveraged by HTTP.
- [[cURL]] - Client used to generate test traffic.
- [[Requests]] / [[Requests Assignment]] - Next steps for parsing/handling.
- [[Go Starter]] - Project structure context.