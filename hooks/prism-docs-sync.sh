#!/usr/bin/env bash
# prism-docs-sync.sh — git pre-commit hook. Keeps the generated doc indexes in sync on every commit.
#
# Install (per clone, since .git/hooks is not committed):
#   ln -sf ../../hooks/prism-docs-sync.sh .git/hooks/pre-commit
#   # or: cp hooks/prism-docs-sync.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
#
# It regenerates the README command index and the OVERVIEW docs index from the filesystem, then
# re-stages those files so the commit includes the update. Add or remove a command or a doc and the
# indexes update themselves. It never rewrites prose.

repo=$(git rev-parse --show-toplevel) || exit 0
bash "$repo/scripts/sync-docs.sh" || true
git add "$repo/README.md" "$repo/OVERVIEW.md" 2>/dev/null || true
exit 0
