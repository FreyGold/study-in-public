| Function                     | Direction | What it does                                    |
| ---------------------------- | --------- | ----------------------------------------------- |
| `json.Marshal()`             | Go → JSON | Converts a Go value into JSON bytes             |
| `json.Unmarshal()`           | JSON → Go | Converts JSON bytes into a Go value             |
| `json.NewEncoder().Encode()` | Go → JSON | Writes JSON directly to a stream (`io.Writer`)  |
| `json.NewDecoder().Decode()` | JSON → Go | Reads JSON directly from a stream (`io.Reader`) |
![[Pasted image 20260817012529.png]]

---
> [!info] Appended on 2026-10-01 20:16
> **Reason:** Conversation covers json.Unmarshal usage, struct tag mapping for nested JSON, and raw byte caching strategies directly relevant to HTTP response decoding.

## JSON Unmarshaling for Cached API Responses

- **Raw byte caching**: Store `[]byte` from `io.ReadAll(res.Body)` directly in cache; avoids redundant `json.Marshal` on write path.
- **Lazy unmarshaling**: Unmarshal cached bytes into struct only when needed (`json.Unmarshal(cached, &target)`).
- **Struct tag mapping**: Only define fields along the path to target data; parser ignores omitted siblings. Nest structs to match JSON hierarchy (e.g., `PokemonEncounters []struct { Pokemon struct { Name string `json:\"name\"` } `json:\"pokemon\"` } `json:\"pokemon_encounters\"`).
- **Generation tooling**: Use [JSON-to-Go](https://mholt.github.io/json-to-go/) or editor plugins to auto-generate structs from sample payloads, then prune unused fields.

```go
// Cache stores raw response bytes
cfg.Cache.Add(url, body)

// Later: unmarshal for use
var locations LocationAreaResponse
json.Unmarshal(cached, &locations)
cfg.Next = locations.Next
```
