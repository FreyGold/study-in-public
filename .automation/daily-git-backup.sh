#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPO_DIR="/home/frey/Fedora Backup/Treasury"
readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/treasury-daily-git-backup"
readonly SUCCESS_FILE="$STATE_DIR/last-successful-date"
readonly PENDING_FILE="$STATE_DIR/pending-date"
readonly LOG_FILE="$STATE_DIR/backup.log"

mkdir -p "$STATE_DIR"
exec >>"$LOG_FILE" 2>&1

printf '\n[%s] Daily Git backup check started\n' "$(date --iso-8601=seconds)"

# Avoid overlapping runs if a push takes longer than an hour.
exec 9>"$STATE_DIR/lock"
if ! flock -n 9; then
  echo "Another backup run is active; exiting."
  exit 0
fi

today=$(date +%F)
if (( $(date +%s) >= $(date -d "$today 19:00" +%s) )); then
  due_date=$today
else
  due_date=$(date -d 'yesterday' +%F)
fi

last_successful_date=""
if [[ -f "$SUCCESS_FILE" ]]; then
  read -r last_successful_date < "$SUCCESS_FILE" || true
fi

# On the first run, do not invent a missed backup from before this automation
# was installed. A pre-19:00 installation begins with today's 19:00 deadline.
if [[ -z "$last_successful_date" && ! -f "$PENDING_FILE" && "$due_date" != "$today" ]]; then
  printf '%s\n' "$due_date" > "$SUCCESS_FILE"
  echo "Initialized schedule; the first backup is due today at 19:00."
  exit 0
fi

if [[ "$last_successful_date" == "$due_date" || "$last_successful_date" > "$due_date" ]]; then
  echo "Backup for $due_date was already pushed."
  exit 0
fi

cd "$REPO_DIR"
git rev-parse --is-inside-work-tree >/dev/null

pending_date=""
if [[ -f "$PENDING_FILE" ]]; then
  read -r pending_date < "$PENDING_FILE" || true
fi

if [[ -z "$pending_date" ]]; then
  git add -A
  git commit --allow-empty -m "chore(backup): daily snapshot $due_date"
  printf '%s\n' "$due_date" > "$PENDING_FILE"
  pending_date=$due_date
else
  echo "Retrying the unconfirmed push for $pending_date."
fi

# HEAD:main makes the intended remote branch explicit even if the local branch
# name is changed later. The success marker is written only after push succeeds.
git push origin HEAD:main
printf '%s\n' "$pending_date" > "$SUCCESS_FILE"
rm -f "$PENDING_FILE"

echo "Backup for $pending_date was pushed successfully."
