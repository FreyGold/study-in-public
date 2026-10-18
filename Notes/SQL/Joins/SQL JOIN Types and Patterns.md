---
title: "SQL JOIN Types and Patterns"
aliases: []
tags:
  - notes/DB/SQL/Joins
  - status/seedling
created: "2026-08-30"
summary: "Master INNER, OUTER, self, and anti-joins; understand chaining for multi-table queries."
---

> [!summary] Key Takeaways
> **Core Insight:** JOIN types define match retention; self-joins link a table to itself; anti-joins find non-matching rows.

## JOIN Type Behavior
| Join Type          | Returns                                      | Unmatched Rows Handling       |
|--------------------|----------------------------------------------|-------------------------------|
| INNER JOIN         | Matching rows from both tables               | Excluded entirely             |
| LEFT JOIN          | All left table rows + matching right         | NULL on right side            |
| RIGHT JOIN         | All right table rows + matching left         | NULL on left side             |
| FULL JOIN          | All rows from both tables                    | NULL wherever no match        |
| CROSS JOIN         | Cartesian product (every A with every B)     | No ON condition               |

## Self-Join Patterns
- **Concept:** Join a table to itself using aliases
- **Use Cases:** Hierarchies (employees/managers), referrals (members/referrers)
- **Example:** Members who recommended others (INNER self-join)
  ```sql
  SELECT rec.firstname AS recfname, rec.surname AS recsname
  FROM cd.members AS rec
  JOIN cd.members AS mem ON rec.memid = mem.recommendedby
  ORDER BY rec.surname, rec.firstname;
  ```
- **Include All Members** (LEFT self-join for members with no recommender):
  ```sql
  SELECT 
    mem.firstname AS memfname, 
    mem.surname AS memsname, 
    rec.firstname AS recfname, 
    rec.surname AS recsname
  FROM cd.members AS mem
  LEFT JOIN cd.members AS rec ON rec.memid = mem.recommendedby
  ORDER BY mem.surname, mem.firstname;
  ```

## Anti-Join (LEFT JOIN ... IS NULL)
- **Pattern:** Find rows in left table with **no match** in right table
- **Example:** Members who haven't recommended anyone
  ```sql
  SELECT mem.firstname, mem.surname
  FROM cd.members AS mem
  LEFT JOIN cd.members AS rec ON mem.memid = rec.recommendedby
  WHERE rec.memid IS NULL  -- No matching referral
  ORDER BY mem.surname, mem.firstname;
  ```

## Joining Three+ Tables
- **Process:** Chain JOINs sequentially
  ```sql
  SELECT 
    m.firstname || ' ' || m.surname AS member_name,
    f.name AS facility_name,
    b.starttime
  FROM cd.members AS m
  JOIN cd.bookings AS b ON m.memid = b.memid
  JOIN cd.facilities AS f ON b.facid = f.facid
  ORDER BY b.starttime;
  ```
- **Flexibility:** Mix join types (e.g., LEFT JOIN then INNER JOIN)
- **ON Conditions:** Can reference columns from any prior table in the chain