# Get
## Go HTTP GET Request

1. **Create request**
   ```go
   req, err := http.NewRequest("GET", url, nil)
   ```

2. **Set headers**
   ```go
   req.Header.Set("X-API-Key", apiKey)
   ```

3. **Send request**
   ```go
   res, err := client.Do(req)
   ```

4. **Close response body**
   ```go
   defer res.Body.Close()
   ```

5. **Check HTTP status**
   ```go
   if res.StatusCode < 200 || res.StatusCode >= 300 {
       // handle error
   }
   ```

6. **Decode response**
   ```go
   var user User
   err = json.NewDecoder(res.Body).Decode(&user)
   ```
   `JSON → User`

## Flow

`Request → Headers → Do → Status → Decode → User`

## Notes

- GET requests normally don't have a request body, so use `nil` in `http.NewRequest`.
- Use `req.URL.Query()` to add query parameters.
- Reuse an `http.Client` in real applications.



# Post
## Go HTTP POST Request

1. **Marshal data**
   ```go
   jsonData, err := json.Marshal(data)
   ```
   `User → JSON []byte`

2. **Create request**
   ```go
   req, err := http.NewRequest("POST", url, bytes.NewReader(jsonData))
   ```

3. **Set headers**
   ```go
   req.Header.Set("Content-Type", "application/json")
   req.Header.Set("X-API-Key", apiKey)
   ```

4. **Send request**
   ```go
   res, err := client.Do(req)
   ```

5. **Close response body**
   ```go
   defer res.Body.Close()
   ```

6. **Check HTTP status**
   ```go
   if res.StatusCode < 200 || res.StatusCode >= 300 {
       // handle error
   }
   ```

7. **Decode response**
   ```go
   err = json.NewDecoder(res.Body).Decode(&user)
   ```
   `JSON → User`

## Flow

`User → Marshal → Request → Headers → Do → Status → Decode → User`

## Notes

- `bytes.NewBuffer(jsonData)` and `bytes.NewReader(jsonData)` both work with `[]byte`.
- Reuse an `http.Client` in real applications instead of creating one per request.


## HTTP PUT in Go

> [!summary] Key Takeaways
> - **No Helper Function:** Go's `net/http` lacks an `http.Put` helper (unlike `Get`/`Post`).
> - **Manual Construction:** Requires building a raw `*http.Request` and executing via `http.Client.Do()`.
> - **Idempotency:** PUT is idempotent; safe to retry identical requests without side effects (unlike POST).

### Implementation Pattern
- **Create Request:** `req, _ := http.NewRequest(http.MethodPut, url, bodyReader)`
- **Set Headers:** `req.Header.Set("Content-Type", "application/json")` (typically required).
- **Execute:** `resp, err := client.Do(req)`

### POST vs. PUT Semantics

| Feature | POST | PUT |
| :--- | :--- | :--- |
| **Primary Use** | Create new resources (append/process) | Create **or** Replace resource at specific URI |
| **Idempotency** | ❌ Non-idempotent (repeats create duplicates) | ✅ Idempotent (repeats yield same state) |
| **URI Target** | Collection URI (`/users`) | Specific Resource URI (`/users/bob`) |
| **Body Semantics** | Instructions for processing | Complete representation of target resource |

> [!tip] Best Practice
> Use PUT for **full resource replacement** at a known URL. Use [[HTTP PATCH]] for partial updates. Ensure the request body contains the *entire* desired resource state.

---
> [!info] Appended on 2026-10-01 20:16
> **Reason:** Conversation demonstrates replacing `json.NewDecoder` with `io.ReadAll` to capture raw bytes for both caching and unmarshaling, a key HTTP client pattern.

## Capturing Raw Response Bytes for Caching

Replace `json.NewDecoder(res.Body).Decode(&v)` with `io.ReadAll` when you need to cache the raw response:

```go
res, err := http.Get(url)
if err != nil { return err }
defer func() { _ = res.Body.Close() }()

body, err := io.ReadAll(res.Body)
if err != nil { return err }

// Cache raw bytes
cache.Add(url, body)

// Unmarshal for immediate use
var data TargetStruct
if err := json.Unmarshal(body, &data); err != nil { return err }
```

- `io.ReadAll` returns `[]byte` suitable for direct cache storage.
- Single read satisfies both caching and parsing; no double-read or re-marshaling needed.
- Wrap `Close()` in `defer func() { _ = res.Body.Close() }()` to satisfy linters without ignoring errors.
