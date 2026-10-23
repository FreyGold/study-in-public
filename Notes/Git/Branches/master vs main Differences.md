# master vs main Differences

Git treats `master` and `main` identically as commit pointers; neither has built-in privileges. Differences come from convention and platform defaults.

| Feature | master | main |
|---|---|---|
| Origin | Historical default (2005–2020) | Adopted late 2020 by GitHub, GitLab, and community |
| GitHub default | Legacy repos (pre-Oct 2020) | New repos via web or `gh` |
| Local default | Default unless configured | Requires `git config --global init.defaultBranch main` on older Git |

Implications:
- Pushing `master` to a repo defaulting to `main` creates a separate branch, not the default.
- CI/CD workflows often filter on `branches: [ main ]`.
- Hosting platforms commonly deploy `main` by default.
- Older tutorials may hardcode `master`.

Best practice:

```bash
git config --global init.defaultBranch main
```