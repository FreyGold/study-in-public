---
title: "RESTful API Fundamentals"
aliases: ["REST Architecture"]
tags:
  - notes/http
  - notes/api-design
  - status/seedling
created: "2026-08-19"
summary: "REST is a stateless, resource-oriented architectural style for HTTP APIs that enforces separation between client and server through standardized conventions."
---

> [!summary] Key Takeaways
> **Core Insight:** REST decouples client and server implementations by mandating stateless, resource-based interactions over HTTP, enabling predictable, language-agnostic APIs.

## Core Principles

- **Resource-Oriented:** Interact with **resources** (nouns) not commands (verbs) — e.g., `GET /issues` not `GET /getIssues`.
- **Stateless:** Server retains no client context; each request contains all information needed. Application state lives in resources, not sessions.
- **Separate & Agnostic:** Client/server evolve independently; contract defined by resource names and HTTP semantics.
- **Uniform Interface:** Standard methods (`GET`, `POST`, `PUT`, `DELETE`) map to CRUD operations on resources.

## HTTP Method Semantics

| Method | Action | Idempotent | Safe |
|--------|--------|------------|------|
| `GET`    | Read resource      | Yes  | Yes |
| `POST`   | Create resource    | No   | No  |
| `PUT`    | Replace resource   | Yes  | No  |
| `DELETE` | Remove resource    | Yes  | No  |

## URL Structure

- **Version prefix:** `/v1/` — enables backward-compatible evolution.
- **Context segment:** `/courses_rest_api/learn-http/` — identifies API scope.
- **Resource collection:** `/projects`, `/users`, `/issues` — plural nouns denote collections.
- **Resource instance:** `/issues/42` — identifier targets single resource.

### Jello API Examples

```text
https://api.boot.dev/v1/courses_rest_api/learn-http/projects
https://api.boot.dev/v1/courses_rest_api/learn-http/users
https://api.boot.dev/v1/courses_rest_api/learn-http/issues
```

- Base path encodes **version**, **course**, and **resource type**.
- No action verbs in path — HTTP method conveys intent.

## Related Concepts

- [[Requests]] — HTTP request/response cycle underpinning REST interactions.
- **Idempotency** — Critical for reliable retries; `GET`, `PUT`, `DELETE` are idempotent.
- **Content Negotiation** — `Accept`/`Content-Type` headers decouple representation from resource.