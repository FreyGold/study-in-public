s# Rename Local Branch master to main

Rename the current branch locally:

```bash
git branch -m master main
```

Verify the change:

```bash
git branch
```

Expected output: `* main`.

Push the renamed branch and set upstream tracking:

```bash
git push -u origin main
```