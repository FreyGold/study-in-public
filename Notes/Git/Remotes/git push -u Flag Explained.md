'# git push -u Flag Explained

`-u` is short for `--set-upstream`. It links the current local branch to the specified remote branch.

Benefits:
- Shorter commands: plain `git push` or `git pull` targets the linked remote branch.
- Status tracking: `git status` shows ahead, behind, or up to date with the remote.

Use `-u` only on the first push of a new branch. Afterward, plain `git push` is sufficient.