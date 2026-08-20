

## cURL POST Requests

> [!summary] Key Takeaway
> Use **`-X POST`** to set the method and **`-d`** for the payload; always wrap JSON in **single quotes** and set the `Content-Type` header explicitly.

### Syntax Patterns

- **Form Data:** `curl -X POST <url> -d "param1=value1&param2=value2"`
- **JSON Payload:**
  ```bash
  curl -X POST <url> \
    -H "Content-Type: application/json" \
    -d '{"key":"value"}'
  ```

### Assignment: Create User

**Endpoint:** `https://api.boot.dev/v1/courses_rest_api/learn-http/users`
**Output:** `/tmp/user.json`

```bash
curl -X POST "https://api.boot.dev/v1/courses_rest_api/learn-http/users" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "QA Job Safety",
    "experience": 2,
    "remote": true,
    "user": {
      "name": "Dan",
      "location": "NOR",
      "age": 29
    }
  }' > /tmp/user.json
```

### Critical Rules
- **`-X POST`** (uppercase X), not `-x` (lowercase x, which configures proxy).
- **Single quotes** around JSON prevent shell expansion of braces and variables.
- Redirect stdout with `> /tmp/user.json` to capture response for test verification.

## cURL `-d` Flag Behavior

> [!summary] Core Rule
> **`-d` / `--data` always sends a request body** (HTTP POST by default), never URL query parameters.

### Mechanics
- **Default Action**: Sends data as **Body** with header `Content-Type: application/x-www-form-urlencoded`.
- **Query Params**: Must be appended manually to the URL (e.g., `curl "url?key=val"`).
- **`-G` / `--get` Switch**: Forces `-d` data into **URL Query String** (changes method to GET).

### Quick Reference

| Flag | Data Destination | HTTP Method | Content-Type Header |
| :--- | :--- | :--- | :--- |
| `-d "k=v"` | **Request Body** | POST | `application/x-www-form-urlencoded` |
| `-G -d "k=v"` | **URL Query String** | GET | *(None)* |
| `--data-raw` | **Request Body** (Literal, no `@` file read) | POST | `application/x-www-form-urlencoded` |
| `--data-binary` | **Request Body** (Binary safe, no newline strip) | POST | `application/octet-stream` |

### Pro Tips
- **JSON Body**: Use `-H "Content-Type: application/json" -d '{"k":"v"}'`.
- **Multiple `-d`**: Concatenated with `&` (e.g., `-d a=1 -d b=2` → `a=1&b=2`).
- **File Upload**: `-d @filename` reads from file (use `--data-binary @file` for strict binary).

> **See also:** [[cURL]], [[RESTful API Fundamentals]], [[Requests]]
