| Function                     | Direction | What it does                                    |
| ---------------------------- | --------- | ----------------------------------------------- |
| `json.Marshal()`             | Go → JSON | Converts a Go value into JSON bytes             |
| `json.Unmarshal()`           | JSON → Go | Converts JSON bytes into a Go value             |
| `json.NewEncoder().Encode()` | Go → JSON | Writes JSON directly to a stream (`io.Writer`)  |
| `json.NewDecoder().Decode()` | JSON → Go | Reads JSON directly from a stream (`io.Reader`) |
![[Pasted image 20260817012529.png]]