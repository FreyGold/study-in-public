---
title: "DISTINCT in SQL"
aliases: []
tags:
  - notes/DB/SQL/DISTINCT
  - status/seedling
created: "2026-08-30"
summary: "Understand standard DISTINCT for duplicate rows and PostgreSQL's DISTINCT ON for column-specific uniqueness."
---

> [!summary] Key Takeaways
> **Core Insight:** Standard DISTINCT deduplicates entire selected rows; DISTINCT ON keeps first row per group based on ORDER BY.

## Standard DISTINCT
- **Behavior:** Evaluates uniqueness across **all selected columns** combined
- **Example:**
  ```sql
  SELECT DISTINCT firstname, surname
  FROM cd.members;
  ```
  Returns unique `(firstname, surname)` pairs. John Smith and John Doe both appear (different surnames).

## DISTINCT ON (PostgreSQL-Specific)
- **Behavior:** Keeps **first row** per unique value in specified expression(s), ordered by ORDER BY
- **Rule:** Columns in `DISTINCT ON (...)` must match leftmost columns in `ORDER BY`
- **Example:** Most recent booking per facility
  ```sql
  SELECT DISTINCT ON (facid) 
    facid, 
    starttime, 
    slots
  FROM cd.bookings
  ORDER BY facid, starttime DESC;  -- Newest first per facid
  ```
- **Usage:** Control which row is kept via ORDER BY (e.g., latest, oldest, highest score)