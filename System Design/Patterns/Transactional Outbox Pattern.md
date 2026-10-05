# Transactional Outbox Pattern

> [!summary] Key Takeaways
> **Core Insight:** A dual write (DB + message broker) cannot be atomic. The outbox pattern writes both to the *same* database transaction, then a separate relay publishes events — eliminating the "DB committed, message lost" or "message sent, DB rolled back" failure modes.

## The Dual-Write Problem
```
Application
    ├──→ Database (COMMIT) ──→ Success
    └──→ Message Broker (PUBLISH) ──→ FAIL (network, broker down)
```
- If DB commits but publish fails → event never sent → downstream inconsistency.
- If publish succeeds but DB rolls back → phantom event processed → corruption.

## Transactional Outbox Solution

### Schema
```sql
CREATE TABLE outbox (
    id           BIGSERIAL PRIMARY KEY,
    aggregate_id UUID NOT NULL,
    event_type   TEXT NOT NULL,
    payload      JSONB NOT NULL,
    created_at   TIMESTAMPTZ DEFAULT now(),
    published_at TIMESTAMPTZ
);
```

### Write Path (Single Transaction)
```sql
BEGIN;
INSERT INTO orders ...;
INSERT INTO outbox (aggregate_id, event_type, payload)
VALUES (order_id, 'OrderCreated', '{"order_id": "..."}');
COMMIT;
```

### Relay (Separate Process)
- Polls `outbox WHERE published_at IS NULL ORDER BY created_at`.
- Publishes to broker.
- Updates `published_at = now()` on success.
- **At-least-once delivery** → downstream consumers still need idempotency.

## Variants
| Variant | Description |
|---------|-------------|
| **Polling relay** | Simple; runs every N seconds; latency = poll interval. |
| **Transaction log tailing (CDC)** | Tools like Debezium read WAL/binlog → publish; lower latency, more ops complexity. |
| **Dual-write to outbox table + Kafka** | Application writes to outbox; Kafka Connect sources from outbox. |

## When to Use
- Microservices needing reliable event propagation.
- Anywhere "DB update + notify external system" occurs.
- **Prerequisite:** You must already feel the pain of dual-write failures (lost events, phantom events) — otherwise YAGNI.

## Relation to Previous Drills
- Queue experiment showed **consumer-side** idempotency (redelivered messages).
- Outbox solves **producer-side** reliability (events not lost on DB commit).
- Together: end-to-end exactly-once *semantics* via at-least-once transport + idempotent ends.

---