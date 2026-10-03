---
title: "Date Handling in SQL"
aliases: []
tags:
  - notes/DB/SQL/Dates
  - status/seedling
created: "2026-08-30"
summary: "Learn efficient date filtering, essential functions, and performance best practices in SQL."
---

> [!summary] Key Takeaways
> **Core Insight:** Always use date ranges (>= start AND < end_next) for sargable queries; leverage DATE_TRUNC, EXTRACT, and INTERVAL for manipulations.

## Date Filtering Best Practices
- **Use Range Comparisons** (Sargable - uses indexes):
  ```sql
  WHERE b.starttime >= '2012-09-14' 
    AND b.starttime < '2012-09-15'  -- Covers entire day
  ```
- **Avoid Column Wrappers** (Prevents index use):
  ```sql
  -- ❌ Sequential scan: forces full table scan
  WHERE b.starttime::date = '2012-09-14'
  ```
  *Exception:* Create expression index: `CREATE INDEX ON bookings ((starttime::date));`

## Essential Date Functions (PostgreSQL)
- **Extract Parts:** `EXTRACT(MONTH FROM joindate)` or `DATE_PART('month', joindate)`
- **Date Arithmetic:** `joindate + INTERVAL '1 month'`
- **Truncation:** `DATE_TRUNC('month', joindate)` → first day of month
- **Current Time:** `NOW()`, `CURRENT_DATE`, `CURRENT_TIMESTAMP`