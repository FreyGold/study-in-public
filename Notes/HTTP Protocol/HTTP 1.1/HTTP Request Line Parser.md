---
title: "HTTP Request Line Parser"
aliases: ["Request Parser", "HTTP/1.1 RequestLine"]
tags:
  - notes/go
  - notes/http
  - status/seedling
created: "2026-08-22"
summary: "A minimal Go parser that reads an HTTP/1.1 request line from an `io.Reader`, validating method casing, version, and structure before returning a structured `Request` object."
---

> [!example] Visual Mind Map
> **Excalidraw Overview:** [[Excalidrawings/HTTP Protocol/HTTP 1.1/HTTP Request Line Parser.excalidraw|HTTP Request Line Parser Diagram]]

> [!summary] Key Takeaways
> **Core Insight:** This parser implements a strict, single-pass extraction of the HTTP Request Line (`METHOD TARGET HTTP/1.1`), enforcing uppercase methods and HTTP/1.1 compliance before handing off to higher-layer logic.

## Core Structures

| Struct | Fields | Purpose |
| :--- | :--- | :--- |
| **Request** | `RequestLine RequestLine` | Top-level container for the parsed request. |
| **RequestLine** | `Method`, `RequestTarget`, `HttpVersion` (all `string`) | Represents the start-line of an HTTP/1.1 request (RFC 9112 §3). |

## Validation Rules

| Check | Condition | Error Message |
| :--- | :--- | :--- |
| **Part Count** | `len(parts) < 3` | `"malformed request line"` |
| **Method Case** | `strings.ToUpper(method) != method` | `"method of RequestLine must be all Upper"` |
| **HTTP Version** | `version != "HTTP/1.1"` | `"version must be 1.1"` |

## Code Reference

```go
package request

import (
	"errors"
	"io"
	"strings"
)

type Request struct {
	RequestLine RequestLine
}

type RequestLine struct {
	HttpVersion   string
	RequestTarget string
	Method        string
}

func RequestFromReader(reader io.Reader) (*Request, error) {
	bytes, err := io.ReadAll(reader)
	if err != nil {
		return nil, err
	}

	reqLine, err := parseRequestLine(string(bytes))
	if err != nil {
		return nil, err
	}

	return &Request{RequestLine: reqLine}, nil
}

func parseRequestLine(str string) (RequestLine, error) {
	reqLine := strings.Split(str, "\r\n")[0]
	parts := strings.Split(reqLine, " ")

	if len(parts) < 3 {
		return RequestLine{}, errors.New("malformed request line")
	}

	if strings.ToUpper(parts[0]) != parts[0] {
		return RequestLine{}, errors.New("method of RequestLine must be all Upper")
	}

	versionParts := strings.Split(parts[2], "/")
	if len(versionParts) < 2 || versionParts[1] != "1.1" {
		return RequestLine{}, errors.New("version must be 1.1")
	}

	return RequestLine{
		Method:        parts[0],
		RequestTarget: parts[1],
		HttpVersion:   versionParts[1],
	}, nil
}
```

## Integration Points

- **Input**: Implements `io.Reader` consumer → compatible with `net.Conn`, `bufio.Reader`, test buffers.
- **Output**: Returns `*Request` → ready for [[Requests]] handling, routing, or [[Decoding]] headers/body.
- **Error Handling**: Returns standard `error` sentinel values → aligns with [[Error Handling]] patterns.