# Cache-Aside Pattern with Redis

> [!summary] Key Takeaways
> **Core Insight:** Cache-aside puts the application in charge of cache population and invalidation. It trades three-round-trip misses for reduced load on hot data, but demands explicit handling of staleness and cache unavailability.

## Experiment Flow (CLI-Driven)

### 1. Cache Miss → Fill → Hit
```bash
# Miss
redis-cli GET product:1        # (nil)
psql -c "SELECT price_cents FROM products WHERE id=1;"
redis-cli SETEX product:1 30 1999  # TTL 30s

# Hit
redis-cli GET product:1        # "1999"
```

### 2. TTL Expiration
- Wait >30 seconds → `GET` returns `(nil)` → next read repopulates from DB.

### 3. Invalidation on Write
```bash
psql -c "UPDATE products SET price_cents=2499 WHERE id=1;"
redis-cli DEL product:1        # Explicit delete on write
```

### 4. Cache Down → DB Fallback
```bash
docker stop redis
redis-cli GET product:1        # Connection refused
psql -c "SELECT price_cents FROM products WHERE id=1;"  # Works
```
- **Lesson:** Cache failure must degrade gracefully, not crash the app. (The Node script initially crashed on unhandled `error` event—fixed by attaching a permanent error listener.)

### 5. Checkout Bypasses Cache
- Checkout reads directly from Postgres for current price/stock.
- Cache only for browse reads where slight staleness is acceptable.

## Reflection Answers (from experiment)
| Question | Answer |
|----------|--------|
| Cache unavailable? | App falls back to DB; latency spikes but service survives. |
| Cached price old? | TTL bounds staleness; explicit `DEL` on write eliminates it for critical paths. |
| Should checkout trust cache? | **No**—checkout reads live DB. Cache for catalog only. |
| How long should data live? | TTL = business tolerance for staleness (e.g., 30s for prices, longer for static content). |

## Key Implementation Guardrails
- **Never crash on cache error:** Attach `error` listener on Redis client; log and fallback.
- **Bound retries:** Cap reconnect attempts to avoid log spam.
- **Separate read paths:** Browse → cache; Checkout → DB.

---