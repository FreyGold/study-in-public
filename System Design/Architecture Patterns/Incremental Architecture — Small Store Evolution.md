> [!example] Useful diagram
> **Excalidraw:** [[Excalidrawings/System Design/Architecture Patterns/Incremental Architecture — Small Store Evolution.excalidraw|Incremental Architecture — Small Store Evolution Diagram]]

# Incremental Architecture — Small Store Evolution

> [!summary] Key Takeaways
> **Core Insight:** Build architecture incrementally: each component must solve a stated requirement and its new failure mode must be acknowledged. Remove anything without a stated requirement.

## Stage 0 — Single Server (App + DB)
- **Solved:** Nothing yet (baseline).
- **New failure:** Single point of failure; limited concurrency.

## Stage 1 — Load Balancer + Second App Server
- **Solved:** No single app server takes whole store down; zero-downtime deploys.
- **New failure:** Load balancer is new SPOF; app servers must be stateless (session affinity breaks).

## Stage 2 — DB Replication (Primary + Read Replica)
- **Solved:** Read traffic (catalog) offloaded from write traffic (checkout); replica is hot standby.
- **New failure:** Replication lag → stale price/stock at checkout.

## Stage 3 — Cache (Cache-Aside) in Front of DB
- **Solved:** Popular products cached → reduced DB load, lower latency.
- **New failure:** Cache staleness after price update; cold cache on deploy → thundering herd on DB.

## Stage 4 — Queue for Async Work (Emails, Receipts)
- **Solved:** Checkout non-blocking; traffic spikes absorbed in queue.
- **New failure:** Worker crash mid-job → message redelivered → duplicate emails unless handler idempotent.

## Explicitly Omitted: Sharding
- **Reason:** Small store data/write volume fits single primary + replica. Sharding cost (rebalancing, cross-shard joins, hardware) not earned without stated huge-scale requirement.

## Final Architecture (5 Components)
```
Client → Load Balancer → App Servers (stateless)
                    ↓
              Cache (Redis)
                    ↓
              Primary DB ←→ Read Replica
                    ↓
              Queue (RabbitMQ) → Workers
```

---