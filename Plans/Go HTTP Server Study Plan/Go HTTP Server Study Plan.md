> [!summary] Sprint Overview
> **Goal:** Build production-grade HTTP servers in Go while maintaining algorithmic sharpness (LeetCode) and full-stack breadth (Frontend + YouTube deep-dives).

## Daily Time Budget (6 h)

| Block | Duration | Focus | Method |
|-------|----------|-------|--------|
| 🌅 **Morning Algorithm** | 1 h | LeetCode (1 problem) | Pattern-based: Array → Two Pointers → Sliding Window → Trees → Graphs → DP |
| ☕ **Mid-Morning Deep Dive** | 3 h | Go HTTP Coursework | Follow course sequence below; code-along + notes in `Go/HTTP/Protocol/` |
| 🍴 **Lunch / Break** | — | — | — |
| 🎬 **Afternoon YouTube** | 1 h | Curated Playlist | One video + implementation/notes |
| 🌐 **Late Afternoon Frontend** | 1 h | React/TypeScript | Component library → small feature → deploy |

## 3-Month Course Sequence (from catalog)

| Month | Course | Est. Hours | Target Completion | Key Deliverable |
|-------|--------|------------|-------------------|-----------------|
| **1** | **Build an HTTP Server in Go** (custom) | ~30 | Days 1–10 | `tcp-server/` with request-line parser, headers, chunked body |
| **1** | **Learn Web Security in Go** | ~20 | Days 11–20 | TLS, JWT, rate-limiting middleware added to server |
| **2** | **Build a Pokedex in Go** (API + DB) | ~25 | Days 21–35 | CRUD API, PostgreSQL, migrations, OpenAPI spec |
| **2** | **Advanced Concurrency Patterns** (supplement) | ~15 | Days 36–45 | Worker pools, graceful shutdown, context propagation |
| **3** | **Capstone: Distributed Cache / Proxy** | ~40 | Days 46–80 | Redis-compatible cache or HTTP/2 reverse proxy |
| **3** | **Polish & Portfolio** | ~20 | Days 81–90 | Docs, benchmarks, CI/CD, deploy to Fly.io / GCP Cloud Run |

> **Note:** Course hours are estimates from catalog (14–30 h each). Adjust daily 3 h block pace; spill-over eats into weekend buffer.

## Weekly Rhythm

| Day | LeetCode Pattern | YouTube Theme | Frontend Focus |
|-----|------------------|---------------|----------------|
| Mon | Arrays / Hashing | Go Internals | React Hooks / State |
| Tue | Two Pointers | Networking / TLS | TypeScript Types |
| Wed | Sliding Window | Concurrency | Component Library (Radix/Shadcn) |
| Thu | Trees / Graphs | System Design | Testing (Vitest/RTL) |
| Fri | Dynamic Programming | Performance / pprof | Build & Deploy (Vercel/Netlify) |
| Sat | **Mock Contest (2h)** | **Project Work (2h)** | **Portfolio Polish (2h)** |
| Sun | Review / Rest | Review / Rest | Review / Rest |

## Milestone Gates

| Gate | Date | Criteria |
|------|------|----------|
| **Gate 1** | Day 10 | HTTP/1.1 server passes `httptest` suite (GET, POST, chunked, pipelining) |
| **Gate 2** | Day 20 | Server handles 10k concurrent TLS connections with <5 ms p99 latency |
| **Gate 3** | Day 45 | Pokedex API documented, tested, deployed with DB migrations |
| **Gate 4** | Day 80 | Capstone handles target load benchmark; README + architecture diagram |
| **Gate 5** | Day 90 | All repos public, blog post written, demo video recorded |

## Tracking Template (copy per week)

```markdown
## Week {{n}} ({{date}})
- [ ] LeetCode: 7/7 ✅ | Patterns: {{list}}
- [ ] Go Course: {{course}} — {{hours}}/{{target}} h
- [ ] YouTube: 5/5 videos → notes in `Theoretical/`
- [ ] Frontend: {{component/feature}} deployed to {{url}}
- [ ] **Blocker / Retro:** {{one sentence}}
```

## Resource Links
- **LeetCode:** [NeetCode 150](https://neetcode.io/roadmap) / [Grind 75](https://www.techinterviewhandbook.org/grind75)
- **YouTube Playlists:** Go Internals (Franciscu), System Design (Hussein Nasser), Concurrency (Boot.dev)
- **Frontend:** [React Beta Docs](https://react.dev/learn), [TypeScript Handbook](https://www.typescriptlang.org/docs/), [Shadcn UI](https://ui.shadcn.com/)

---
*Generated 2026-10-03 — adjust dates as you start.*