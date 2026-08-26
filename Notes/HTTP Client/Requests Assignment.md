

## HTTP Client Patterns: User CRUD Operations
> [!summary] Assignment Overview
> Implementation of **PUT** (update) and **GET** (retrieve) operations against a RESTful User API using Go's `net/http` package. Demonstrates request construction, JSON marshaling/unmarshaling, header management, and critical error handling patterns.

---

### `updateUser` – PUT Request with JSON Body
> [!tip] Key Lines & Importance
> - **`json.Marshal(data)`**: Serializes the `User` struct to JSON bytes for the request payload. *Fails if struct tags are invalid or data contains non-serializable types.*
> - **`bytes.NewBuffer(jsonData)`**: Wraps byte slice in `io.Reader` required by `http.NewRequest` body parameter.
> - **`req.Header.Set("Content-Type", "application/json")`**: **Critical** – Informs server how to parse the body. Missing this causes `415 Unsupported Media Type` or silent parse failures.
> - **`req.Header.Set("X-API-Key", apiKey)`**: AuthZ mechanism. Must match server expectation (custom header vs `Authorization: Bearer`).
> - **`client.Do(req)`**: Executes the round trip. **Must check returned error** (network issues, DNS, TLS) *before* reading `res.Body`.
> - **`json.NewDecoder(res.Body).Decode(&user)`**: Streams decode directly from response body (efficient). **Must check error** (invalid JSON, schema mismatch) and **close body** (defer `res.Body.Close()`).

```go
// Pattern: Robust PUT Implementation
func updateUser(baseURL, id, apiKey string, data User) (User, error) {
	fullURL := baseURL + "/" + id
	jsonData, err := json.Marshal(data)
	if err != nil { return User{}, err } // 1. Handle marshal error

	req, err := http.NewRequest(http.MethodPut, fullURL, bytes.NewBuffer(jsonData))
	if err != nil { return User{}, err } // 2. Handle request creation error

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", apiKey)

	res, err := http.DefaultClient.Do(req) // 3. Use DefaultClient or configured client
	if err != nil { return User{}, err }   // 4. Handle transport error
	defer res.Body.Close()                  // 5. Prevent resource leak

	if res.StatusCode >= 400 {              // 6. Check HTTP status before decode
		return User{}, fmt.Errorf("API error: %s", res.Status)
	}

	var user User
	if err := json.NewDecoder(res.Body).Decode(&user); err != nil { // 7. Handle decode error
		return User{}, err
	}
	return user, nil
}
```

---

### `getUserById` – GET Request (Query/Path Param)
> [!warning] Critical Bugs in Provided Snippet
> The reference implementation **ignores all errors** (`_` blank identifier), leading to silent failures, nil pointer dereferences on `res.Body`, and impossible debugging.
> - `req, _ := http.NewRequest(...)` -> Ignores invalid URL/method errors.
> - `res, _ := client.Do(req)` -> Ignores network failures; `res` is `nil` on error -> **Panic on `res.Body`**.
> - `json.NewDecoder(res.Body).Decode(&user)` -> Ignores invalid JSON/empty body errors.

> [!tip] Key Lines & Importance (Corrected Pattern)
> - **`http.NewRequest(http.MethodGet, fullURL, nil)`**: `nil` body for GET. Parameters encoded in URL path (`/id`) or `req.URL.Query()`.
> - **Header Auth Only**: No `Content-Type` needed (no body).
> - **Status Code Check**: Essential to distinguish `404 Not Found` (valid "empty" result) from `200 OK` vs `5xx` server errors.

```go
// Pattern: Robust GET Implementation
func getUserById(baseURL, id, apiKey string) (User, error) {
	fullURL := baseURL + "/" + id
	req, err := http.NewRequest(http.MethodGet, fullURL, nil)
	if err != nil { return User{}, err }

	req.Header.Set("X-API-Key", apiKey)

	res, err := http.DefaultClient.Do(req)
	if err != nil { return User{}, err }
	defer res.Body.Close()

	if res.StatusCode == http.StatusNotFound {
		return User{}, ErrUserNotFound // Define custom sentinel error
	}
	if res.StatusCode >= 400 {
		return User{}, fmt.Errorf("API error: %s", res.Status)
	}

	var user User
	if err := json.NewDecoder(res.Body).Decode(&user); err != nil {
		return User{}, err
	}
	return user, nil
}
```

---

### [[Go Standard Library]] / [[net/http]] Best Practices Checklist
- [ ] **Always handle errors** from `Marshal`, `NewRequest`, `Do`, `Decode`.
- [ ] **Always `defer res.Body.Close()`** after checking `res != nil`.
- [ ] **Check `res.StatusCode`** before decoding; `2xx` != Success in all APIs.
- [ ] **Use `http.DefaultClient`** or a shared `&http.Client{Timeout: ...}` to prevent hanging connections.
- [ ] **Prefer `json.NewDecoder(stream)`** over `json.Unmarshal(bytes)` for streaming efficiency.
- [ ] **Define Sentinel Errors** (e.g., `ErrUserNotFound`) for callers to handle specific cases via `errors.Is`.
