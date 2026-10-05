# Four-Step System Design Interview Method

> [!summary] Key Takeaways
> **Core Insight:** Treat system design interviews as a structured conversation you lead through four deliberate steps—requirements, high-level design, core components, and scaling—each grounded in explicit trade-offs.

## The Four Steps

1. **Outline use cases, constraints, and assumptions**
   - Ask: Who uses it? How? How many users? Data volume? Requests/second? Read/write ratio?
   - Establish scope before proposing solutions.

2. **Create a high-level design**
   - Sketch main components and connections.
   - Justify each component against requirements.

3. **Design core components**
   - Dive into schema, algorithms, APIs for each core piece.
   - Make concrete technology choices.

4. **Scale the design**
   - Identify bottlenecks given constraints.
   - Apply load balancers, horizontal scaling, caching, sharding as trade-offs.
   - **Principle:** Everything is a trade-off—no free scaling.

## Application in This Exercise
- Used to structure the small-store evolution (Stages 0–4).
- Each added component traced to a specific requirement from Step 1.
- Sharding explicitly omitted because no stated requirement justified its cost.

---