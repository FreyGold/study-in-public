# Roadmap v2 — Pre-Military → Military (reading-only) → Job Search (03/2028+)

> Every parent topic below is broken into subtopics, and every subtopic into a concrete task — something you can actually sit down and finish in a session, not "go learn X." Phase 1 = needs a computer, do now. Phase 2 = pure reading, no phone/laptop. Phase 3 = rebuild + job search after 03/2028.

---

## PHASE 1 — Next ~12 Weeks (needs a computer) `#phase1`

### Boot.dev's full "Go" catalog, mapped onto this plan

Every current Go course on Boot.dev, where it plugs into the sections below, and whether it's load-bearing or optional. HTTP Protocol, Clients, and Servers are three separate courses and three separate sections below (B, C, D) — no longer bundled together.

|Course|Hours|Maps to|Priority|
|---|---|---|---|
|Learn Go|20h|Section A|**Core**|
|Learn the HTTP Protocol in Go|16h|Section B|**Core**|
|Learn HTTP Clients in Go|14h|Section C|**Core**|
|Learn HTTP Servers in Go|24h|Section D|**Core**|
|Learn CI/CD with GitHub Actions, Docker and Go|20h|Section E|**Core**|
|Learn Pub/Sub in RabbitMQ and Go|32h|Section F|**Core**|
|Learn File Servers and CDNs with S3 and CloudFront|24h|Section H|**Core**|
|Learn Cryptography in Go|16h|Section O|Optional|
|Learn Logging and Observability in Go|16h|Section P|Optional|
|Build a Pokedex in Go (project)|24h|Section C|Optional|
|Build a Web Scraper in Go (project)|6h|Section C|Optional, cheap|
|Build a Blog Aggregator in Go (project)|24h|Section K warm-up|Optional|

**Reality check:** the 7 core courses alone total ~150 hours of course content — before your own hands-on drills in G/I/J (which aren't covered by any Boot.dev course), the capstone build, LeetCode, and German. That's already close to filling 12 weeks on its own. Treat the 5 optional items as "if there's time left over," not as things to schedule in from day one.

### A. Go — language depth (Boot.dev "Learn Go," 145 lessons / 20h + your own drills)

- [x] **Types & variables**
    - [ ] Zero values for every primitive type — write them down without checking, then verify
    - [ ] Type conversion rules (why Go won't implicitly convert int→float64, and where that bites you)
    - [ ] Named types vs type aliases — build a small example where the distinction matters
- [x] **Structs & methods**
    - [ ] Value receivers vs pointer receivers — write a bug on purpose (mutate via value receiver, watch it not persist), then fix it
    - [ ] Embedding (struct composition) vs inheritance — reimplement one class hierarchy from a past React/Express project as embedded Go structs
    - [ ] Struct tags for JSON (`json:"name,omitempty"`) — marshal/unmarshal a nested struct with optional fields
- [x] **Interfaces**
    - [ ] Implicit satisfaction — write two unrelated structs that satisfy the same interface without saying so explicitly
    - [ ] The empty interface (`any`) and where it's an anti-pattern vs legitimate
    - [ ] Type assertions and type switches — write a function that branches on concrete type from an interface param
- [x] **Error handling**
    - [ ] The `error` interface itself — implement a custom error type
    - [ ] Wrapping (`fmt.Errorf("...: %w", err)`) and unwrapping (`errors.Is`, `errors.As`) — build a small call chain (3 functions deep) and wrap errors at each level, then unwrap at the top
    - [ ] When to `panic` vs return an `error` — write down your own rule in one sentence
- [x] **Concurrency**
    - [ ] Goroutines — launch 10, have them all print, observe non-determinism
    - [ ] Unbuffered vs buffered channels — build one example that deadlocks on purpose, then fix it
    - [ ] `select` statement — implement a timeout on a channel read
    - [ ] `sync.WaitGroup`, `sync.Mutex`, `sync.Once` — build a concurrent counter, break it without the mutex (race condition), fix it, run with `go run -race` to confirm
    - [ ] Common deadlock patterns — write down 3 ways to deadlock a Go program from memory
- [x] **Generics**
    - [ ] Type parameters and constraints — write one generic function (e.g. `Map`/`Filter` over a slice)
    - [ ] Decide, in writing, when you'd reach for generics vs an interface — this is a judgment call worth having an opinion on
- [x] **Testing**
    - [ ] Table-driven tests — convert one existing function into a table-driven test suite
    - [ ] Subtests with `t.Run`
    - [ ] Mocking via interfaces (no mocking library) — mock a DB dependency for a service function
    - [ ] One benchmark using `testing.B`
- [x] **Context package**
    - [ ] Cancellation propagation through a call chain
    - [ ] Deadlines/timeouts on a slow operation
    - [ ] Write down why over-using `context.Value` for passing data is considered bad practice
- [x] **Standard library**
    - [ ] `io.Reader`/`io.Writer` — build one small thing that streams data instead of loading it all into memory
    - [ ] `net/http` from the standard library only (before reaching for a router) — build one working endpoint

Boot.dev course: https://www.boot.dev/courses/learn-golang

### B. HTTP Protocol Fundamentals (Boot.dev "Learn the HTTP Protocol in Go," 41 lessons / 16h)

Do this before Clients and Servers — you can't build either well without knowing what's actually on the wire. This is a full 16-hour course in its own right, not a footnote.

- [ ] Parse a raw HTTP request by hand (start line, headers, body) — don't use `net/http` for this exercise, work from the raw bytes
- [ ] Parse a raw HTTP response by hand the same way
- [ ] Status code categories (1xx–5xx) — write down what each category means without looking it up, then check yourself against specifics (200 vs 201 vs 204, 301 vs 302 vs 307, 401 vs 403, 429, 500 vs 502 vs 503 vs 504)
- [ ] Headers that actually matter in practice: `Content-Type`, `Content-Length`, `Cache-Control`, `ETag`, `Authorization` — explain what each controls
- [ ] Keep-alive / connection reuse — explain why it matters for performance, and what changes with HTTP/1.0 vs 1.1 defaults
- [ ] Chunked transfer encoding — explain when/why it's used instead of `Content-Length`
- [ ] URL structure — scheme, host, port, path, query string, fragment — parse one apart manually

### C. HTTP Clients (Boot.dev "Learn HTTP Clients in Go," 55 lessons / 14h)

- [ ] Make GET/POST requests with headers and query params
- [ ] Set timeouts and cancel via context on `http.Client`
- [ ] Retry logic with exponential backoff for a flaky endpoint (simulate flakiness yourself)
- [ ] **JSON**
    - [ ] Encode/decode structs, handle unknown/extra fields gracefully
    - [ ] Custom `MarshalJSON`/`UnmarshalJSON` for one type with non-trivial serialization (e.g. a custom date format)
- [ ] Connection pooling — explain what `http.Transport` controls and why creating a new `http.Client` per request is a common performance mistake
- [ ] Optional reinforcement project: **Build a Pokedex in Go** (13 lessons / 24h, guided project) — a second rep on client-side HTTP, skip if you're confident already
- [ ] Optional, cheap reinforcement: **Build a Web Scraper in Go** (13 lessons / 6h, guided project) — low time cost, decent if you have a spare afternoon

### D. HTTP Servers (Boot.dev "Learn HTTP Servers in Go," 51 lessons / 24h)

This is the single biggest HTTP course of the three — bigger than Clients, bigger than the Protocol course. Treat it as such.

- [ ] **Routing**
    - [ ] Build a router by hand first (just `net/http` + a switch on path), then redo it with `chi` or similar — feel the difference
    - [ ] Route params and query param parsing/validation
- [ ] **Middleware**
    - [ ] Write logging, panic-recovery, and auth middleware, in that order, and explain why order matters
    - [ ] Explain the middleware chaining pattern in your own words (each middleware wraps the next handler)
- [ ] **Response encoding**
    - [ ] Encode server responses to JSON with correct status codes and headers (same skillset as Section C's JSON subtasks, applied to responses instead of requests)
- [ ] **Auth**
    - [ ] Implement JWT issue + verify from scratch (not just a library call — understand what's actually in the token)
    - [ ] Write down, in your own words, session-based vs token-based auth trade-offs
    - [ ] Implement refresh token rotation
- [ ] **Webhooks**
    - [ ] Verify a webhook signature (HMAC) by hand
    - [ ] Handle webhook delivery idempotently (dedupe on event ID)
- [ ] **Shutdown**
    - [ ] Implement graceful shutdown (catch SIGTERM, stop accepting new requests, drain in-flight ones)

Optional, unrelated to the HTTP thread but a decent standalone rust-remover: **Build a Blog Aggregator in Go** (18 lessons / 24h, guided project) — a CLI RSS aggregator using Go + Postgres. Good as a guided warm-up before your own capstone (Section K) if you'd rather not jump straight into designing it yourself. Skip it if you'd rather put that time straight into the capstone.

### E. Docker & CI/CD — properly, not "get the idea" (Boot.dev "Learn CI/CD with GitHub Actions, Docker and Go," 37 lessons / 20h — this one course covers both halves below)

- [ ] **Images & layers**
    - [ ] Explain layer caching in your own words, then prove you understand it by reordering a Dockerfile's `COPY`/`RUN` lines to break the cache, then fix it
    - [ ] Write a `.dockerignore` for a real project and explain why each line is there
- [ ] **Dockerfile craft**
    - [ ] Multi-stage build (build stage + slim runtime stage) for one of your Go or Node apps — compare final image size before/after
    - [ ] Pin base image versions (no more `latest`), explain why
    - [ ] Run the container as a non-root user
- [ ] **Storage**
    - [ ] Bind mount vs named volume — set up Postgres with a named volume, kill the container, confirm data survives
    - [ ] Explain when you'd use a bind mount instead (e.g. local dev hot-reload)
- [ ] **Networking**
    - [ ] Default bridge network — get two containers talking to each other by container name (Docker's internal DNS)
    - [ ] Expose a port to the host vs keep a service internal-only (e.g. DB should never be host-exposed in prod)
- [ ] **docker-compose**
    - [ ] Multi-service compose file: app + Postgres + Redis
    - [ ] `depends_on` with healthchecks (not just startup order — actual readiness)
    - [ ] Environment variables via `.env` file, not hardcoded
- [ ] **Debugging**
    - [ ] `docker exec -it` into a running container to inspect state
    - [ ] Read and interpret logs from a crashing container, fix the crash
- [ ] **Publishing**
    - [ ] Tag an image properly (semantic version, not just `latest`) and push to a registry (Docker Hub or GHCR)
- [ ] **Podman-specific**
    - [ ] Repeat the compose exercise with `podman compose` or `podman-compose`, note what differs (rootless by default, no daemon)
- [ ] **CI/CD (GitHub Actions)**
    - [ ] Write a workflow that runs your Go tests on every push
    - [ ] Extend it to build the Docker image in CI
    - [ ] Extend it to push the built image to a registry on merge to main
    - [ ] Explain, in writing, the difference between CI and CD, and where your pipeline currently stops (probably CI-only, no auto-deploy — that's fine, just know the boundary)

### F. Queues & Messaging — real depth, not "I know they exist" (Boot.dev "Learn Pub/Sub in RabbitMQ and Go," 37 lessons / 32h)

- [ ] **Core model**
    - [ ] Producer / broker / consumer roles, in your own words
    - [ ] Queue (point-to-point) vs topic (pub/sub fan-out) — write one sentence on when you'd use each
- [ ] **Delivery semantics**
    - [ ] At-most-once vs at-least-once vs exactly-once — explain why exactly-once is usually "at-least-once + idempotent consumer" in practice, not a real broker guarantee
    - [ ] Design an idempotency key for a payment-processing-style message, on paper
- [ ] **Ordering & partitioning**
    - [ ] Why Kafka only guarantees order _within_ a partition, not globally
    - [ ] Pick a partition key for a made-up use case (e.g. "order events") and justify it
- [ ] **Consumption patterns**
    - [ ] Work queue (competing consumers, each message processed once) vs fan-out (every consumer group gets every message) — build both with RabbitMQ
    - [ ] Consumer groups — spin up 2 consumers in the same group, confirm messages are split between them, not duplicated
- [ ] **Failure handling**
    - [ ] Dead-letter queue — configure one, force a message to fail repeatedly, watch it land in the DLQ
    - [ ] Retry policy with exponential backoff and a max retry count
    - [ ] Kill a consumer mid-processing (simulate a crash) and observe what happens to the in-flight message — does it get redelivered?
- [ ] **Backpressure**
    - [ ] Deliberately make a consumer slower than the producer, watch queue depth grow, explain what you'd do about it (scale consumers, shed load, apply backpressure to producer)
- [ ] **Broker choice**
    - [ ] Write a short comparison table: RabbitMQ vs Kafka vs SQS — throughput, ordering guarantees, replay-ability, operational complexity
- [ ] **Hands-on build**
    - [ ] Producer + worker in Go, backed by RabbitMQ, for the capstone project (Section K)
    - [ ] Optional stretch: repeat the same producer/consumer exercise with Kafka to feel the operational difference

Boot.dev "Learn Pub/Sub in RabbitMQ and Go" chapters: Pub/Sub Architecture → Message Brokers → Publishers & Queues → Subscribers & Routing → Delivery → Serialization → Scalability. At 32 hours this is the single longest course in the catalog — that's a signal it's the one worth not rushing, since it's also your stated weakest area.

### G. Caching — real depth

- [ ] **Strategies**
    - [ ] Cache-aside (lazy loading) — implement it in front of a real Postgres query
    - [ ] Write-through and write-behind — explain the trade-offs of each vs cache-aside (consistency vs latency vs complexity)
- [ ] **Invalidation**
    - [ ] TTL-only vs explicit invalidation on write — implement explicit invalidation for your cache-aside example
    - [ ] Explain the "cache invalidation is one of the two hard problems" joke in your own words — what actually makes it hard
- [ ] **Stampede protection**
    - [ ] Reproduce a cache stampede on purpose (expire a hot key, hit it with concurrent requests, watch them all hit the DB)
    - [ ] Fix it with either a lock (single request repopulates, others wait) or jittered TTLs
- [ ] **Eviction**
    - [ ] LRU vs LFU vs random eviction — explain when each makes sense
    - [ ] Look at Redis's `maxmemory-policy` options and pick one for a made-up workload, justify it
- [ ] **Redis beyond KV**
    - [ ] Use a sorted set for something (e.g. a leaderboard) instead of a plain key
    - [ ] Use Redis pub/sub for a simple real-time notification, distinct from its use as a cache
- [ ] **Layering**
    - [ ] Diagram (on paper) a request path through CDN → app cache → DB, and note what's cached at each layer and why

### H. Object storage — real depth (Boot.dev "Learn File Servers and CDNs with S3 and CloudFront," 43 lessons / 24h)

This course uses real S3 + CloudFront. If you'd rather avoid AWS costs while drilling, run the same exercises against MinIO locally (S3-compatible API) and only touch real S3/CloudFront for the CDN-specific parts that MinIO can't replicate.

- [ ] **Model**
    - [ ] Object storage vs filesystem vs database — flat namespace, no directory tree, metadata-plus-blob model, immutability of objects (you replace, not edit)
    - [ ] Explain in one paragraph why you wouldn't store a mutable, frequently-updated record in object storage
- [ ] **Consistency**
    - [ ] Look up S3's consistency model and write down what "read-after-write consistency" actually guarantees (and what it doesn't)
- [ ] **Large files**
    - [ ] Implement a multipart upload for a large file against MinIO
- [ ] **Access & security**
    - [ ] Implement presigned URL upload/download — explain why the app shouldn't proxy the file bytes itself
    - [ ] Explain the difference between a public bucket, a signed URL, and IAM-scoped access
- [ ] **Lifecycle**
    - [ ] Look at storage classes (hot/cold/archive) and lifecycle policies, write one sentence on when you'd auto-transition an object
- [ ] **Hands-on build**
    - [ ] MinIO running locally via Docker, wired into the capstone project's image upload flow (Section K)

### I. Rate limiting — real depth

- [ ] **Algorithms**
    - [ ] Fixed window — implement it, then identify its flaw (burst at window boundary)
    - [ ] Sliding window log and sliding window counter — explain the memory/accuracy trade-off between them
    - [ ] Token bucket — implement this one for real (see below), explain why it handles bursts more gracefully
    - [ ] Leaky bucket — explain how it differs from token bucket (smooths output rate vs allows bursts)
- [ ] **Distributed correctness**
    - [ ] Explain why an in-memory counter breaks the moment you have 2+ app instances behind a load balancer
    - [ ] Implement token bucket rate limiting in Redis using an atomic Lua script (not a naive GET-then-SET, which race-conditions)
- [ ] **Scope & UX**
    - [ ] Decide and justify: per-IP vs per-user vs per-API-key vs per-endpoint for a made-up API
    - [ ] Return proper `429 Too Many Requests` with a `Retry-After` header
- [ ] **Verification**
    - [ ] Load test your limiter with concurrent requests (e.g. `hey` or `k6`) and confirm it actually holds the limit under load, not just in a single-threaded test

### J. Distributed systems fundamentals (conceptual — this is your real "system design" gap, and it's meant to bridge into Phase 2's DDIA reading)

- [ ] **CAP theorem**
    - [ ] State it precisely, then write down one common way people misuse/oversimplify it
- [ ] **Consistency models**
    - [ ] Strong vs eventual vs causal vs read-your-own-writes — one concrete real-world example of each
- [ ] **Partitioning**
    - [ ] Range-based vs hash-based partitioning — trade-offs
    - [ ] Consistent hashing — explain why it's needed (what breaks with naive `hash(key) % N` when N changes) and roughly how it solves rebalancing
- [ ] **Replication**
    - [ ] Single-leader vs multi-leader vs leaderless/quorum — write down a failure scenario for each where it behaves badly
    - [ ] Quorum math: for N replicas, W writes, R reads — when do you get strong consistency (W+R>N)? Work through one numeric example
- [ ] **Failure detection**
    - [ ] Heartbeats/timeouts — explain why you can't distinguish "node is slow" from "node is dead" with certainty
    - [ ] Gossip protocols — one-paragraph conceptual explanation
- [ ] **Consensus** (conceptual only — you're not implementing Raft)
    - [ ] What problem Paxos/Raft solve (getting distributed nodes to agree on one value/log despite failures) and why it's hard
- [ ] **Distributed transactions**
    - [ ] Two-phase commit vs the saga pattern — explain why sagas are more common in microservice architectures (2PC's blocking/availability cost)
- [ ] **Time**
    - [ ] Why wall-clock time can't be trusted for ordering across nodes (clock skew) — what a logical/vector clock is trying to solve, conceptually

> This section connects straight into Phase 2: DDIA Part II (Replication → Partitioning → Transactions → Trouble with Distributed Systems → Consistency and Consensus) is the deep-dive on everything above — that's intentional, so the concepts aren't brand new when you hit the book.

### K. Capstone project — ties sections A, D, E, F, G, H, and I together

- [ ] Define scope on paper first: an image/file upload service — API accepts upload → job pushed to a queue → worker resizes/processes the file → result stored in object storage (MinIO) → metadata cached in Redis (cache-aside) → endpoint is rate-limited (token bucket in Redis) → everything containerized with docker-compose
- [ ] Build the API layer (Go, from Section D)
- [ ] Build the queue + worker (from Section F)
- [ ] Wire in object storage (from Section H)
- [ ] Wire in caching (from Section G)
- [ ] Wire in rate limiting (from Section I)
- [ ] Containerize the whole thing properly (from Section E) — multi-stage builds, compose file, healthchecks
- [ ] Write a README documenting the architecture decisions and trade-offs you made — this doubles as interview prep material later

### L. LeetCode

- [ ] Finish the Blind 150 (in progress)
- [ ] Once done: revisit ones you struggled with, re-derive the pattern closed-book, don't just grind new ones

### M. German — start now while you have audio/phone

- [ ] Get **Menschen A1.1** (Kursbuch + Arbeitsbuch)
- [ ] Get **Schritte Übungsgrammatik** (A1–B1)
- [ ] Work through pronunciation with Duolingo or an audio course now — this access disappears later
- [ ] Buy the Phase 2 graded readers now (list below) so they're physically in hand before you lose the ability to order things

### N. Logistics for military prep

- [ ] Order every Phase 2 book physically now
- [ ] Buy a proper notebook + pens for notes and the German journal
- [ ] Build a Leitner box (index cards + a few graduated boxes) — replaces Anki since there's no phone
- [ ] Ask in Egyptian dev Facebook/LinkedIn groups (search for recent conscripts, not old threads) exactly what's allowed where you're headed — books-per-bag limits, actual downtime, phone rules — since this varies by unit and general web search didn't surface reliable current answers

### O. Cryptography in Go — optional / stretch (Boot.dev "Learn Cryptography in Go," 78 lessons / 16h)

Do this if the 7 core courses are done with time to spare. Otherwise it's fine material for Phase 3, once you're back to coding daily.

- [ ] **Hashing**
    - [ ] Password hashing with bcrypt or argon2 — implement it, explain why plain SHA-256 is wrong for passwords (too fast, no salt by default)
- [ ] **Symmetric encryption**
    - [ ] AES-GCM encrypt/decrypt a payload — explain what the "GCM" part buys you over plain AES (authentication, not just confidentiality)
- [ ] **Asymmetric encryption**
    - [ ] Generate an RSA or ECDSA keypair, sign and verify a message
    - [ ] Connect this back to Section D's JWT task — JWTs are signed with exactly this mechanism
- [ ] **TLS conceptual tie-in**
    - [ ] Explain in your own words what a TLS handshake accomplishes (this pairs with the TLS chapter in Phase 2's _High Performance Browser Networking_)

### P. Logging & Observability in Go — optional / stretch (Boot.dev "Learn Logging and Observability in Go," 73 lessons / 16h)

Same priority note as above — genuinely useful, not urgent given your stated gaps.

- [ ] **Structured logging**
    - [ ] Replace `fmt.Println` debugging in one of your existing projects with structured logs (levels, fields, not string concatenation)
- [ ] **Metrics**
    - [ ] Instrument one endpoint with a counter (requests), a gauge (in-flight requests), and a histogram (latency) — Prometheus-style
- [ ] **Tracing**
    - [ ] Explain, conceptually, what a trace ID propagated across services buys you that logs alone don't (tying separate services' logs into one request's story)
- [ ] **Connects to Phase 2 reading**
    - [ ] This section is the practical counterpart to _Site Reliability Engineering_'s SLI/SLO chapters and _Release It!_'s stability patterns — read those with this hands-on context already in place if you do this section first

---

## PHASE 2 — During Service, Reading Only, No Phone `#phase2`

### System design & distributed systems

- [ ] **System Design Interview, Vol. 1** — Alex Xu
    - [ ] The 4-step framework chapter — read twice, it's the scaffolding for everything after
    - [ ] Rate limiter, consistent hashing, key-value store chapters — these map directly to what you built in Phase 1, read them as "here's the theory behind what I already built"
    - [ ] Remaining chapters (URL shortener, web crawler, notification system, news feed, chat system, search autocomplete) — one per sitting, sketch the diagram from memory afterward
- [ ] **Designing Data-Intensive Applications** — Martin Kleppmann (the main event — go slow)
    - [ ] Part I: Reliable, Scalable, Maintainable Applications — foundations chapter
    - [ ] Part I: Data Models and Query Languages
    - [ ] Part I: Storage and Retrieval (B-trees vs LSM-trees — this connects to your "indexing" knowledge, goes much deeper)
    - [ ] Part I: Encoding and Evolution
    - [ ] Part II: Replication — connects to Phase 1 Section J
    - [ ] Part II: Partitioning — connects to Phase 1 Section J
    - [ ] Part II: Transactions
    - [ ] Part II: The Trouble with Distributed Systems — connects to Phase 1 Section J (failure detection, clocks)
    - [ ] Part II: Consistency and Consensus — connects to Phase 1 Section J
    - [ ] Part III: Batch Processing
    - [ ] Part III: Stream Processing — connects back to your Phase 1 queues work (Section F)
    - [ ] Part III: The Future of Data Systems
- [ ] **System Design Interview, Vol. 2** — Alex Xu (read after Vol. 1 + most of DDIA)
    - [ ] Proximity/location-based systems chapters
    - [ ] Distributed message queue chapter — direct sequel to your Phase 1 queues work
    - [ ] Remaining chapters (metrics monitoring, ad click aggregation, hotel reservation, distributed email)
- [ ] **Fundamentals of Software Architecture** — Neal Ford & Mark Richards
    - [ ] Architectural characteristics / trade-off analysis chapters (the vocabulary-building part)
    - [ ] Architecture styles chapters — skim for breadth, don't force depth on ones irrelevant to backend work
- [ ] **Building Microservices (2nd ed.)** — Sam Newman (read selectively)
    - [ ] Service decomposition chapters
    - [ ] Inter-service communication chapters
    - [ ] The saga pattern / distributed transactions chapter — direct follow-up to DDIA's transactions chapter
- [ ] **Release It!** — Michael Nygard
    - [ ] Stability patterns (circuit breaker, bulkhead, timeout) — take notes, these are commonly asked about in interviews and rarely covered elsewhere
- [ ] **Site Reliability Engineering** — Google (free online, print/bind before you go in)
    - [ ] Chapters on SLIs/SLOs/error budgets
    - [ ] Chapters on incident response / postmortems

### Backend & networking depth

- [ ] **High Performance Browser Networking** — Ilya Grigorik (free online — print it before you go in)
    - [ ] TCP fundamentals chapter — connects to your load balancing knowledge
    - [ ] TLS chapter
    - [ ] HTTP/1.1, HTTP/2 chapters — pairs directly with Phase 1 Section B
    - [ ] CDN chapter — connects to Phase 1's caching-layer diagram exercise (Section G)
- [ ] **The Go Programming Language** — Donovan & Kernighan
    - [ ] Read goroutines/channels chapters even without a compiler — mark specific exercises to actually type out once you're back
    - [ ] Interfaces chapter — cross-reference against what you already built in Phase 1 Section A

### Optional, if time allows

- [ ] **Database Internals** — Alex Petrov
- [ ] **Domain-Driven Design Distilled** — Vaughn Vernon
- [ ] **Clean Architecture** — Robert C. Martin (skip if already internalized from practice)

### German (reading-only mode)

- [ ] Continue Menschen — do written exercises in a separate notebook, self-check with answer keys
- [ ] Schritte Übungsgrammatik — one grammar point at a time
- [ ] Graded readers in order: _Café in Berlin_ (A1–A2) → _Nachbar Nr. 5_ (A1) → _Erste Stufe_ reader → move up once these feel easy
- [ ] Daily German journal — 3–4 handwritten sentences minimum, your only output practice without a phone
- [ ] Leitner box vocab review, daily

---

## PHASE 3 — After 03/2028: Rebuild + Job Search `#phase3`

- [ ] Rebuild a Docker project from scratch, no reference, to restore muscle memory
- [ ] Re-implement one thing from Phase 2 reading in actual code (e.g. a simplified saga, or a proper consistent-hashing ring) — converts theory back into practice
- [ ] Revisit and extend the Phase 1 capstone with anything new from DDIA/Xu (e.g. add proper replication awareness, better partitioning)
- [ ] Refresh LeetCode for a week or two before interviews
- [ ] Boot.dev's **Learn How to Find a Programming Job** course: Strategy → Projects → GitHub Profile → Resume → LinkedIn Profile → Applying → Networking → Interviewing → Relocation
- [ ] Research the _then-current_ Egypt job market specifically at that time — don't rely on anything researched today
- [ ] Run mock interviews (system design + coding) using the frameworks you read during service
- [ ] Ask in Egyptian dev communities how hiring looks right as you're getting out — people finishing service just ahead of you will have the freshest read