---
title: "Finding Extremes with Aggregation"
aliases: []
tags:
  - notes/DB/SQL/Aggregation
  - status/seedling
created: "2026-08-30"
summary: "Use MAX() for latest dates and MIN() for earliest; understand alternatives like ORDER BY LIMIT."
---

> [!summary] Key Takeaways
> **Core Insight:** MAX() efficiently finds the highest value; ORDER BY ... LIMIT 1 is an alternative but less idiomatic.

## Using MAX for Latest Date
- **Pattern:** Aggregate entire column to find maximum (latest) value
  ```sql
  SELECT MAX(joindate) AS latest_signup
  FROM cd.members;
  ```
- **Why Use MAX?**
  - Directly computes extreme value without sorting
  - Clear intent: "give me the maximum"
  - Works with any comparable type (dates, numbers, strings)
- **Output Control:** Alias the result (`AS latest_signup`) for readability

## Alternative: ORDER BY ... LIMIT 1
- **Pattern:** Sort descending and take first row
  ```sql
  SELECT joindate AS latest
  FROM cd.members
  ORDER BY joindate DESC
  LIMIT 1;
  ```
- **Tradeoffs:**
  - Requires full sort (O(n log n)) vs MAX's O(n) scan
  - Less expressive intent (sorting vs extreme-finding)
  - Useful when needing other columns from the extreme row:
    ```sql
    SELECT * 
    FROM cd.members
    ORDER BY joindate DESC
    LIMIT 1;  -- Returns full row of latest member
    ```
- **Note:** MAX(joindate) only returns the date; to get the full row, use ORDER BY LIMIT 1 or a subquery.

## When to Choose Which
- **Prefer MAX()** when you only need the extreme value itself
- **Prefer ORDER BY LIMIT 1** when you need the entire row containing the extreme value
- **Avoid** MAX() with GROUP BY unless you need per-group extremes