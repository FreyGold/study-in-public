---
title: "Ordering and LIMIT in SQL"
aliases: []
tags:
  - notes/DB/SQL/Ordering
  - status/seedling
created: "2026-08-30"
summary: "Master ORDER BY syntax, NULLS positioning, and understand why LIMIT must follow ORDER BY."
---

> [!summary] Key Takeaways
> **Core Insight:** ORDER BY defines sort sequence; LIMIT applies after sorting. Use NULLS FIRST/LAST to control null placement.

## ORDER BY Syntax
- **Direction:** `ASC` (default) or `DESC`
  ```sql
  ORDER BY surname ASC, firstname DESC
  ```
- **NULLS Handling:**
  ```sql
  ORDER BY surname ASC NULLS LAST;  -- Nulls appear after values
  ORDER BY surname DESC NULLS FIRST; -- Nulls appear before values
  ```
- **Multiple Columns:** Sort by first column, then second for ties, etc.

## LIMIT Must Follow ORDER BY
- **Syntactic Requirement:** SQL clause order is fixed:
  ```sql
  SELECT ...
  FROM ...
  WHERE ...
  GROUP BY ...
  HAVING ...
  ORDER BY ...   -- Must come before LIMIT
  LIMIT ...      -- Cannot appear before ORDER BY
  ```
- **Logical Reason:** Database must sort the full result set before selecting top N rows.
- **Workaround for Pre-Sort Sampling:** Use subquery
  ```sql
  SELECT * FROM (
    SELECT * FROM cd.members LIMIT 5  -- Arbitrary 5 rows
  ) AS sub
  ORDER BY surname;  -- Then sort those 5
  ```