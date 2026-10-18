---
title: "UNION and UNION ALL in SQL"
aliases: []
tags:
  - notes/DB/SQL/Set_Operations
  - status/seedling
created: "2026-08-30"
summary: "Learn to combine query results with UNION (distinct) and UNION ALL (preserves duplicates)."
---

> [!summary] Key Takeaways
> **Core Insight:** UNION removes duplicates; UNION ALL keeps all rows and is faster. Both require matching column counts and types.

## UNION vs UNION ALL
- **UNION:** 
  - Automatically removes duplicate rows across combined result sets
  - Requires sorting/hashing for deduplication → slower
  - Example: Combine member surnames and facility names
    ```sql
    SELECT surname FROM cd.members
    UNION
    SELECT name FROM cd.facilities;
    ```
- **UNION ALL:**
  - Preserves all duplicates (e.g., same name in both tables)
  - No deduplication step → significantly faster
  - Use when duplicates are acceptable or impossible
    ```sql
    SELECT surname FROM cd.members
    UNION ALL
    SELECT name FROM cd.facilities;
    ```

## Requirements
- **Same Column Count:** Each SELECT must return identical number of columns
- **Compatible Data Types:** Corresponding columns must be type-compatible (e.g., text/text, integer/integer)
- **Column Names:** Output uses column names from **first** SELECT statement