---
title: "SQL Expressions"
aliases: []
tags:
  - notes/DB/SQL/Expressions
  - status/seedling
created: "2026-08-30"
summary: "Master CASE expressions for conditional logic and string concatenation techniques in SQL."
---

> [!summary] Key Takeaways
> **Core Insight:** Use CASE for row-wise conditional logic and string operators (||, CONCAT, CONCAT_WS) to combine columns into readable output.

## CASE Expression
- **Syntax:** `CASE WHEN condition THEN result [WHEN ...] ELSE default END AS alias`
- **Cheap/Expensive Labeling:**
  ```sql
  SELECT name, monthlymaintenance,
    CASE WHEN monthlymaintenance > 100 THEN 'expensive' ELSE 'cheap' END AS cost_category
  FROM cd.facilities;
  ```
- **Guest vs Member Cost:**
  ```sql
  CASE WHEN m.memid = 0 THEN b.slots * f.guestcost
       ELSE b.slots * f.membercost
  END AS cost
  ```

## String Concatenation
- **|| Operator:** Standard SQL, returns NULL if any input is NULL
  ```sql
  SELECT firstname || ' ' || surname AS full_name FROM cd.members;
  ```
- **CONCAT():** Treats NULL as empty string (PostgreSQL)
  ```sql
  SELECT CONCAT(firstname, ' ', surname) AS full_name FROM cd.members;
  ```
- **CONCAT_WS(sep, ...):** Inserts separator between non-null arguments
  ```sql
  SELECT CONCAT_WS(', ', address, zipcode, telephone) AS contact_info FROM cd.members;
  ```