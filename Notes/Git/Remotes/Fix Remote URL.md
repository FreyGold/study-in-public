# Fix Remote URL

If `origin` was saved with a malformed URL, update it:

```bash
git remote set-url origin https://github.com/FreyGold/go-boilerplate.git
```

Verify:

```bash
git remote -v
```

Expected output:

```
origin  https://github.com/FreyGold/go-boilerplate.git (fetch)
origin  https://github.com/FreyGold/go-boilerplate.git (push)
```

Then commit and push if needed:

```bash
git commit -m "initial commit"
git push -u origin master
```