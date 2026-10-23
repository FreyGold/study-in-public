# Delete Local Branches

Delete local branches `list` and `main`:

```bash
git branch -d list main
```

If Git blocks deletion because of unmerged commits, force-delete:

```bash
git branch -D list main
```

Verify removal:

```bash
git branch
```

Note: `git branch <name>` creates a branch; `git branch` without arguments lists branches.