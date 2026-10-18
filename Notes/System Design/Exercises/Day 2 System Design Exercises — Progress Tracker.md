# Day 2 System Design Exercises — Progress Tracker

> [!summary] Key Takeaways
> **Core Insight:** Five hands-on blocks build a complete mini-system: interface design → scaling reasoning → cache lab → queue lab → failure drills.

## Block Status

| Block | Title | Status | Notes |
|-------|-------|--------|-------|
| 1 | **Smallest Design (100 daily users) + 5 Interfaces** | ⬜ Not started | Define: Create order, Get order, List products, Update inventory, Submit payment — each with input, output, main query, possible failure. |
| 2 | **Scale to 1M Users / 10k RPS / 500 WPS** | 🟡 Partial | Earlier chat did a version with different numbers; redo against *these* targets. You write: problem solved / new failure / stale data handling / recovery for each component addition. |
| 3 | **Cache Experiment** | ✅ Done | Redis-cli/psql walkthrough complete. **Remaining:** Answer 4 reflection questions (cache unavailable, stale price, checkout trust, TTL sizing). |
| 4 | **Queue Experiment** | ⬜ Not started | Design workers (paper or code) so duplicated message → no double email/invoice. RabbitMQ not required. |
| 5 | **Failure Drills** | ⬜ Not started | 6 short scenarios, explained in own words. No tooling needed. |

## Block 1 — Interface Contract Template
```markdown
**Interface Name** — Input: ... Output: ... Main query: `SQL` Possible failure: ...
```

**Example (from curriculum):**
- **List products** — Input: none (or page). Output: `[{id, name, price_cents}]`. Main query: `SELECT id, name, price_cents FROM products ORDER BY id LIMIT 20;`. Possible failure: PG connection pool exhausted → timeout.

## Next Action
**Draft Block 1 interfaces** (4 remaining) using the template above. Paste them for review before moving to Block 2 redo.

---