 ### Four Pillars of Observability

```
┌────────────────────────┐
│     OBSERVABILITY      │
└───────────┬────────────┘
    ┌───────┼────────┬───────┐
    ▼       ▼        ▼       ▼
  1.LOGS 2.METRICS 3.TRACES 4.HEALTH CHECKS
```

1. **Logs (Discrete Events)**: Structured JSON lines recording specific events or errors with metadata at a timestamp. High detail, but expensive to store at high volume.
2. **Metrics (Aggregated Numeric Data)**: Counters, gauges, and histograms measuring overall system performance over time (e.g., request totals, active DB connections, latency percentiles).
3. **Distributed Tracing (Request Journeys)**: Tracks an individual request across service boundaries using a unique `trace_id` to generate flame graphs and pinpoint specific execution bottlenecks.
4. **Health & Readiness Checks**:
   - **Liveness probe (`/livez`)**: Indicates if the process is running or deadlocked.
   - **Readiness probe (`/readyz`)**: Pings dependencies (e.g., PostgreSQL, Redis) to verify if the instance can receive traffic.

### Tooling Systems

- **Managed SaaS (e.g., New Relic)**: Fully hosted platform collecting metrics, traces, and logs via an agent and license key.
- **Self-Hosted Stack (e.g., Prometheus + Grafana)**:
  - **Prometheus**: Time-series database that scrapes `/metrics` endpoints and stores numeric metrics.
  - **Grafana**: Visualization UI that queries time-series databases to render dashboards. Can run locally, in Docker, or on server infrastructure.

### Latency Percentiles (p50, p95, p99)

Percentiles rank response time distributions across a time window:

- **p50 (Median)**: 50% of requests were faster than this value. Represents standard user experience.
- **p95**: 95% of requests were faster than this value. Highlights performance under load or secondary code paths.
- **p99 (Tail Latency)**: 99% of requests were faster than this value; the slowest 1% took longer. Exposes worst-case bottlenecks (GC pauses, DB connection pool contention, cold starts, lock contention).

#### Percentiles vs. Averages

Averages obscure tail latency anomalies. If 99 requests take 10ms and 1 request takes 10,000ms (10 seconds), the average is ~110ms. The average masks that 1% of requests experienced severe degradation, whereas p99 explicitly shows 10,000ms.

#### Impact on Multi-Request User Flows

When a single user action triggers multiple downstream API calls or database queries ($N$), the probability of experiencing at least one tail-latency delay increases:

$$P(\text{at least one slow request}) = 1 - (p)^N$$

For $N = 40$ requests with $p = 0.99$:

$$1 - (0.99)^{40} \approx 33.1\%$$

Thus, a p99 latency issue on individual requests can impact roughly a third of end-user interactions.

#### Prometheus Histogram Buckets

To calculate percentiles efficiently, Prometheus records requests into predefined bucket boundaries (`le="0.05"`, `le="0.1"`, `le="1.0"`) and computes percentiles using `histogram_quantile()`.

### Pairing Metrics with Distributed Tracing

1. **Metric Alert**: Alerts when p99 latency spikes above a defined threshold.
2. **Trace Filtering**: Filter traces for requests exceeding the threshold.
3. **Trace Inspection**: Analyze execution time spent in each span (routing, auth, database query) to isolate the root cause.