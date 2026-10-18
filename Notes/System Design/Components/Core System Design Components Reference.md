# Core System Design Components Reference

> [!summary] Key Takeaways
> **Core Insight:** Each component solves a specific scaling problem but introduces a new failure mode—design by matching components to stated requirements, not by adding "because scale."

## Load Balancer
- **Role:** Distributes requests across app servers; prevents overload, routes away from unhealthy instances.
- **Layers:** Layer 4 (IP/port only, fast) vs Layer 7 (reads request content, flexible routing).
- **Failure mode:** Becomes a new single point of failure → run active-passive/active-active pair.
- **Side effect:** Forces app servers to be stateless; pushes more connections downstream.

## Database Replication
| Pattern | Writes | Reads | Failover | Complexity |
|---------|--------|-------|----------|------------|
| Master-Slave | Master only | Slaves | Promote slave | Low |
| Master-Master | Both | Both | Automatic | High (conflict resolution) |
- **Shared downsides:** Replication lag (stale reads), potential data loss if master fails before replicate.

## Sharding
- Splits data across multiple DBs by key (e.g., user ID, geography).
- **Benefits:** Reduces per-shard load/index size.
- **Costs:** App needs shard-routing logic; cross-shard joins expensive; hot shards possible.
- **Verdict for small store:** Not justified—data/write volume fits single primary + replica.

## Cache (Cache-Aside)
- **Pattern:** Check cache → on miss, load from DB → write to cache → return.
- **Pros:** Simple, only caches requested data.
- **Cons:** Miss = 3 round trips; stale data until TTL expiry or explicit invalidation on write.
- **Other strategies:** Write-through (sync write to cache+DB), Write-behind (async DB flush, risk of loss).

## Message Queues
- **Pattern:** App publishes job → returns immediately → worker processes async → signals completion.
- **Delivery guarantee:** At-least-once (RabbitMQ, SQS) → duplicates possible → **idempotency required**.
- **Back pressure:** Queue fills → reject new requests with "busy" → client retries with exponential backoff.
- **Broker options:** Redis (lightweight, can lose messages), RabbitMQ (AMQP, self-hosted), SQS (hosted, higher latency).

---