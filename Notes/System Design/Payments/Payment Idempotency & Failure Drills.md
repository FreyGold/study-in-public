# Payment Idempotency & Failure Drills

> [!summary] Key Takeaways
> **Core Insight:** Payment systems require idempotency at the API layer (keys), server-side event-driven confirmation (webhooks), and explicit handling of unknown states (timeouts) — never trust client-side responses.

## Stripe Patterns Modeled

### 1. Idempotent Requests
- **Mechanism:** Client generates `Idempotency-Key` (UUID) per *intent*; sends with create request.
- **Server:** Stores `(key, response)` on first request; returns stored response on repeat.
- **Drill:** Submit same payment twice with same key → second returns first result (no double charge).

### 2. Payment Status Verification
- **Rule:** Never trust browser redirect/response as source of truth.
- **Correct:** Use server-side `payment_intent.succeeded` event (webhook) to confirm completion.
- **Reason:** Browser can crash, close, or be manipulated; webhook is server-to-server.

### 3. Webhooks & Retries
- **Behavior:** Stripe retries webhooks on non-2xx response (exponential backoff, up to 72hrs).
- **Requirement:** Webhook handler **must be idempotent** (same event ID processed once).
- **Local testing:** `stripe listen --forward-to localhost:port/webhook` via CLI.

## Failure Drills (Modeled, Not Integrated)

| Scenario                               | Modeling Approach                                                                      |
| -------------------------------------- | -------------------------------------------------------------------------------------- |
| **Timeout — result unknown**           | Submit payment → network hangs → no response. State = `pending`. Do not retry blindly. |
| **Later success event corrects state** | Webhook arrives later (`payment_intent.succeeded`) → update order to `paid`.           |
| **Idempotent retry**                   | Resubmit with same idempotency key → returns original result (success or failure).     |
| **Webhook duplicate**                  | Same event ID delivered twice → handler deduplicates via processed-event table.        |

## Implementation Checklist
- [ ] Generate idempotency key client-side per user *action* (not per retry).
- [ ] Store `(key, response, status)` atomically with payment creation.
- [ ] Webhook handler: verify signature → check processed-event table → process → mark processed.
- [ ] Order state machine: `created` → `pending` → `paid` | `failed` (driven by webhook, not client).
- [ ] Reconciliation job: periodically fetch PaymentIntent status for `pending` orders.

---