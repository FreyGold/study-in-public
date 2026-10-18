---
title: "NULL Handling in SQL"
aliases: []
tags:
  - notes/DB/SQL/NULLS
  - status/seedling
created: "2026-08-30"
summary: "Understand how NULLs affect comparisons, joins, and expressions; use IS NULL and COALESCE safely."
---

> [!summary] Key Takeaways
> **Core Insight:** NULL represents unknown; use IS NULL for checks and COALESCE for defaults; never use = NULL.

## NULL Fundamentals
- **Definition:** NULL = unknown/missing (not zero, empty string, or false)
- **Comparisons:** Any comparison with NULL yields UNKNOWN (not true/false)
  ```sql
  WHERE column = NULL  -- Always false! Use IS NULL instead
  WHERE column IS NULL  -- Correct
  WHERE column IS NOT NULL  -- Correct
  ```

## NULLs in WHERE Clauses
- **Filtering for NULLs:**
  ```sql
  -- Find members with no recommender
  SELECT * FROM cd.members WHERE recommendedby IS NULL;
  ```
- **Excluding NULLs:**
  ```sql
  -- Find members who have a recommender
  SELECT * FROM cd.members WHERE recommendedby IS NOT NULL;
  ```

## NULLs in JOIN Conditions
- **Behavior:** NULL = NULL evaluates to UNKNOWN → no match
  ```sql
  -- This join condition fails when recommendedby is NULL
  ON mem.memid = rec.recommendedby  -- NULL memid won't match NULL recommendedby
  ```
- **Solution:** Use LEFT JOIN to preserve left-side rows when right side is NULL
  ```sql
  -- Keep all members, show NULL for missing recommender info
  FROM cd.members AS mem
  LEFT JOIN cd.members AS rec ON mem.memid = rec.recommendedby
  ```

## NULLs in Expressions
- **Concatenation:** `||` returns NULL if any input is NULL
  ```sql
  SELECT firstname || ' ' || surname  -- Returns NULL if firstname OR surname is NULL
  ```
- **Solution:** Use COALESCE or CONCAT (PostgreSQL) to treat NULL as empty
  ```sql
  SELECT COALESCE(firstname, '') || ' ' || COALESCE(surname, '');
  -- Or PostgreSQL-specific:
  SELECT CONCAT(firstname, ' ', surname);  -- NULL → empty string
  ```
- **Math Operations:** `NULL + 5 = NULL`; use COALESCE for defaults
  ```sql
  SELECT COALESCE(discount, 0) * price;
  ```