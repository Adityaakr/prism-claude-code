#!/usr/bin/env bash
# prism-update.sh — pull the latest Prism source and sync it into an install dir, then prove it landed.
#
# Prism installs by COPYING commands into ~/.claude/commands and hooks into ~/.claude/hooks. Copies
# drift silently. This script closes the loop: pull source, re-copy, verify with the drift check.
# It is the engine behind the /prism-update command, but it also works standalone from the clone.
#
#   bash scripts/prism-update.sh                    # pull, then sync into ~/.claude
#   bash scripts/prism-update.sh --no-pull          # sync the current checkout, don't touch git
#   bash scripts/prism-update.sh --project DIR      # install into DIR/.claude instead of ~/.claude
#   bash scripts/prism-update.sh --commands-dir D --hooks-dir D   # explicit targets
#   bash scripts/prism-update.sh --force            # pull even with local edits to command/hook files
#   bash scripts/prism-update.sh --prune            # also remove installed prism*.md dropped from source
#
# Exit codes: 0 in sync, 1 drift remained, 2 usage / precondition error.

set -uo pipefail

pull=1 force=0 prune=0
cmd_dir="$HOME/.claude/commands"
hook_dir="$HOME/.claude/hooks"

while [ $# -gt 0 ]; do
  case "$1" in
    --no-pull)      pull=0 ;;
    --force)        force=1 ;;
    --prune)        prune=1 ;;
    --project)      shift; cmd_dir="$1/.claude/commands"; hook_dir="$1/.claude/hooks" ;;
    --commands-dir) shift; cmd_dir="$1" ;;
    --hooks-dir)    shift; hook_dir="$1" ;;
    -h|--help)      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

repo="$(cd "$(dirname "$0")" && git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$repo" ] || [ ! -f "$repo/commands/prism.md" ]; then
  echo "error: not inside a Prism clone (no commands/prism.md found)." >&2
  echo "       run this from your prism-claude-code checkout." >&2
  exit 2
fi

ver_before="$(cat "$repo/VERSION" 2>/dev/null || echo unknown)"
head_before="$(git -C "$repo" rev-parse --short HEAD 2>/dev/null || echo unknown)"

# --- pull latest source (safe by default) ---------------------------------
if [ "$pull" -eq 1 ]; then
  # Refuse to pull over local edits to the files we are about to overwrite, unless forced.
  dirty="$(git -C "$repo" status --porcelain -- commands hooks 2>/dev/null)"
  if [ -n "$dirty" ] && [ "$force" -eq 0 ]; then
    echo "local edits to command/hook files would be at risk; skipping git pull."
    echo "commit or stash them, or re-run with --force (or --no-pull to sync as-is):"
    echo "$dirty" | sed 's/^/    /'
  else
    echo "pulling latest source (git pull --ff-only)..."
    if ! git -C "$repo" pull --ff-only 2>&1 | sed 's/^/    /'; then
      echo "    fast-forward pull failed (diverged history?). resolve in the clone, then re-run." >&2
      exit 2
    fi
  fi
fi

ver_after="$(cat "$repo/VERSION" 2>/dev/null || echo unknown)"
head_after="$(git -C "$repo" rev-parse --short HEAD 2>/dev/null || echo unknown)"

# --- sync into the install dir --------------------------------------------
mkdir -p "$cmd_dir" "$hook_dir"
copied=0
for f in "$repo"/commands/prism*.md; do
  [ -e "$f" ] || continue
  install -m 0644 "$f" "$cmd_dir/$(basename "$f")" && copied=$((copied + 1))
done
for f in "$repo"/hooks/prism-*.sh; do
  [ -e "$f" ] || continue
  # test harnesses stay in the repo; only install the runtime hooks
  case "$(basename "$f")" in test-*) continue ;; esac
  install -m 0755 "$f" "$hook_dir/$(basename "$f")"
done
echo "synced $copied commands -> $cmd_dir"
echo "synced hooks -> $hook_dir"

# --- optional prune of commands dropped from source -----------------------
if [ "$prune" -eq 1 ]; then
  for inst in "$cmd_dir"/prism*.md; do
    [ -e "$inst" ] || continue
    name="$(basename "$inst")"
    [ -f "$repo/commands/$name" ] || { rm -f "$inst" && echo "pruned stale: $name"; }
  done
fi

# --- report what changed ---------------------------------------------------
echo
echo "version: $ver_before -> $ver_after   (HEAD $head_before -> $head_after)"
if [ "$head_before" != "$head_after" ] && [ "$head_before" != unknown ]; then
  echo "commits pulled:"
  git -C "$repo" log --oneline "$head_before..$head_after" -- commands hooks CHANGELOG.md 2>/dev/null | sed 's/^/    /'
elif [ "$pull" -eq 1 ]; then
  echo "already at the latest source."
fi

# --- prove it landed -------------------------------------------------------
echo
bash "$repo/scripts/prism-version.sh" --check "$cmd_dir"
rc=$?
echo
echo "done. reload slash commands in Claude Code (restart the session) to pick up changes."
exit $rc
