

## RFC Reference Guide

> [!summary] Key Takeaway
> **HTTP/1.1 implementation relies on RFC 9110 (Semantics) and RFC 9112 (Messaging)** — the modern, split specification replacing the monolithic RFC 7231.

### Core RFCs

| RFC | Status | Role | Notes |
|-----|--------|------|-------|
| **RFC 9110** | Current | **HTTP Semantics** | Methods, status codes, headers, caching, auth. Primary reference. |
| **RFC 9112** | Current | **HTTP/1.1 Messaging** | Wire format: request/response lines, chunked encoding, connection management. Concise, assumes 9110 fluency. |
| RFC 7231 | Obsoleted | Legacy Semantics + Messaging | Superseded by 9110/9112. Verbose, still widely cited. |
| RFC 2616 | Deprecated | Original HTTP/1.1 (1999) | Fully replaced by 7231 → 9110/9112. |

### Reading Strategy
- **Start with RFC 9110** for conceptual model (semantics).
- **Move to RFC 9112** for parsing/serialization logic (messaging).
- **Skim RFC 7231** only for historical context or when debugging legacy interop.

### Related Vault Notes
- [[RFCs]]
- [[HTTP_1.1 Fundamentals]]
