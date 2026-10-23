n# Configure Remote Repository

Link manually:

SSH:

```bash
git remote add origin git@github.com:<YOUR_USERNAME>/<REPO_NAME>.git
```

HTTPS:

```bash
git remote add origin https://github.com/<YOUR_USERNAME>/<REPO_NAME>.git
```

Verify:

```bash
git remote -v
```

Using GitHub CLI (`gh`):

Create and link in one step:

```bash
gh repo create <repo-name> --public --source=. --remote=origin --push
```

Link an existing repo:

```bash
gh repo set-default
```

Attach to current directory:

```bash
gh repo clone <repo-name> .
```

Push after setup:

```bash
git push -u origin master
```