---
title: "Video Streaming Techniques Comparison"
aliases: ["Video Streaming Methods", "HTTP Streaming vs HLS"]
tags:
  - notes/go
  - notes/http
  - notes/networking
  - status/seedling
created: "2026-08-25"
summary: "Compares four video delivery techniques: full memory load, disk streaming with Content-Length, HTTP chunked encoding, and HLS/DASH application-layer segmentation."
---

> [!example] Visual Architecture Diagram
> **Excalidraw Overview:** [[Excalidrawings/Theoretical/Video Streaming Techniques Comparison.excalidraw|Video Streaming Techniques Comparison Architecture]]

> [!summary] Key Takeaways
> **Core Insight:** Choosing a video delivery method depends on whether you know the total size upfront (enabling `Content-Length`) and whether you need adaptive bitrate switching (requiring application-layer segmentation like HLS/DASH).

## Core Techniques

### 1. Full Memory Load (`os.ReadFile`)
- **Mechanism:** Reads entire file into `[]byte` RAM → sends with `Content-Length`.
- **Memory:** **High** (O(file size)). 100GB video = 100GB RAM.
- **Use Case:** Tiny static assets only. **Anti-pattern for video.**

### 2. Disk Streaming (`os.Open` + `io.Copy`) + `Content-Length`
- **Mechanism:** `os.Open` → `file.Stat()` for size → write headers → `io.Copy(w, file)`.
- **Memory:** **Constant/Low** (fixed ~32KB buffer). 100GB video = ~32KB RAM.
- **Requirement:** Total size **must be known** before headers sent.
- **Browser Behavior:** Streams playback immediately as buffer fills (progressive download).

### 3. HTTP Chunked Encoding (`Transfer-Encoding: chunked`)
- **Mechanism:** Single HTTP response; data sent in framed chunks without `Content-Length`.
- **Trigger:** **Size unknown** upfront (live streams, proxies, dynamic generation).
- **Protocol Layer:** HTTP/1.1 transport feature.
- **Limitation:** Single continuous stream; **no mid-stream quality switching**.

### 4. HLS / DASH (TS Chunks) — **Industry Standard for Video**
- **Mechanism:** Video split into 2–10s `.ts` segments + manifest (`.m3u8`/`.mpd`). Client requests each segment via **separate HTTP GET**.
- **Layer:** Application/Media layer (not HTTP transport).
- **Superpowers:**
  - **Adaptive Bitrate (ABR):** Switch resolution per segment (1080p → 480p mid-video).
  - **CDN Friendly:** Static files with exact `Content-Length` cache perfectly.
  - **Resilience:** Failed segment = retry one tiny file, not whole video.

## Decision Matrix

| Scenario | Technique | Why |
| :--- | :--- | :--- |
| Static file, known size, fits RAM | `os.ReadFile` + `Content-Length` | Simplest code (assignment context). |
| Static file, known size, **large** | `os.Open` + `io.Copy` + `Content-Length` | **Production standard** for file serving. Flat memory. |
| Live stream / Proxy / Dynamic gen | HTTP Chunked Encoding | Only option when total bytes unknown *before* sending headers. |
| **On-demand Video Platform** | **HLS / DASH (TS Chunks)** | **Required** for ABR, seeking, CDN caching, multi-device support. |

## Memory & Flow Comparison

```mermaid


flowchart TD
    subgraph MemLoad["1. Full Memory Load (os.ReadFile)"]
        A1["Read ALL bytes into RAM"] --> B1["Write Headers Content-Length"]
        B1 --> C1["Write ["]byte to Socket]
    end

    subgraph DiskStream["2. Disk Streaming (os.Open + io.Copy)"]
        A2["Open File Descriptor"] --> B2["Stat File for Size"]
        B2 --> C2["Write Headers Content-Length"]
        C2 --> D2["Loop: Read 32KB -> Write Socket"]
    end

    subgraph Chunked["3. HTTP Chunked Encoding"]
        A3["Start Response Headers Transfer-Encoding: chunked"]
        A3 --> B3["Loop: Generate Data -> Write Chunk Size + Data"]
        B3 --> C3["Final Zero-Length Chunk"]
    end

    subgraph HLS["4. HLS / DASH (TS Chunks)"]
        A4["Client GET Manifest.m3u8"] --> B4["Client GET segment_001.ts"]
        B4 --> C4["Client GET segment_002.ts"]
        C4 --> D4["... Adaptive Bitrate Logic ..."]
    end

    style MemLoad fill:#ffebee,stroke:#c62828
    style DiskStream fill:#e8f5e9,stroke:#2e7d32
    style Chunked fill:#fff3e0,stroke:#ef6c00
    style HLS fill:#e3f2fd,stroke:#1565c0


```

## Key Distinctions

- **Protocol vs. Application Layer:**
  - **Chunked Encoding** = HTTP Transport Layer (how bytes move on *one* connection).
  - **TS Chunks (HLS)** = Application Layer (how video is *structured* across *many* requests).

- **`os.Open` vs `os.ReadFile` Memory:**
  - `os.ReadFile`: Allocates `[]byte` = **File Size**.
  - `os.Open`: Returns `*os.File` (fd) = **~bytes**. `io.Copy` uses fixed internal buffer.

- **When Chunked is Mandatory:** Streaming `stdout` of a running command, proxying unknown-length upstream response, Server-Sent Events (SSE).

## Related Vault Notes
- [[HTTP Server Implementation Guide]]
- [[HTTP_1.1 Fundamentals]]
- [[OS Networking (TCP, UDP) and HTTP]]
- [[Error Handling]] (for `os.Open` error checking)
- [[Decoding]] (for parsing manifests if implementing HLS client)