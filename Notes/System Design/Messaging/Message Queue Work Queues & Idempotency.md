# Message Queue Work Queues & Idempotency

> [!summary] Key Takeaways
> **Core Insight:** Queues decouple latency-sensitive requests from slow work, but at-least-once delivery makes idempotent consumers mandatory—duplicate processing is a certainty, not an edge case.

## RabbitMQ Work Queue Experiment

### Core Setup
- **Producer:** Sends work messages (e.g., `send_confirmation_email`).
- **Workers (2+):** Compete for messages (round-robin by default).
- **Manual Acknowledgements:** Worker acks *after* successful processing.
- **Failure Simulation:** Kill worker mid-job → message requeued → redelivered to another worker.

### Durability
- **Durable queue:** `queue_declare(durable=true)` — survives broker restart.
- **Persistent messages:** `delivery_mode=2` — written to disk.
- **Both required** for no-loss guarantee across broker restarts.

### Idempotency Drill (Critical)
- **Problem:** Redelivered message → `send_confirmation_email` runs twice.
- **Solution:** Deduplicate at consumer.
  - **Option A:** Processed-message table (`message_id` primary key).
  - **Option B:** Unique operation key (e.g., `order_id + email_type`) — insert or ignore.
- **Test:** Send same invoice message twice → only one email sent.

## Reliability Concepts (from RabbitMQ Docs)
| Concept | Implication |
|---------|-------------|
| At-least-once | Messages *will* be delivered multiple times; design for it. |
| Publisher confirms | Broker acks receipt to producer (prevents producer-side loss). |
| Consumer acks | Manual ack after processing (prevents consumer-side loss). |
| Duplicate handling | **Idempotency** = repeated processing = same intended result as one attempt. |

## Design Checklist for Queue Consumers
- [ ] Manual ack *after* side effects complete.
- [ ] Idempotency key stored *before* or *atomically with* side effect.
- [ ] Durable queue + persistent messages for critical work.
- [ ] Dead-letter queue for messages exceeding retry limit.
- [ ] Monitoring: queue depth, consumer lag, redelivery rate.

---