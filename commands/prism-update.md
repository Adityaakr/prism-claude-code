---
description: Update your installed Prism to the latest source — pull the clone, re-sync commands + hooks into ~/.claude, prove it landed with the drift check, and tell you what is new. Safe and reversible; never touches your project code.
allowed-tools: Bash, Read, Grep, Glob
---
# Prism · Update

Bring the user's installed Prism up to date with the source repo. Prism installs by COPYING command
playbooks into `~/.claude/commands` and hooks into `~/.claude/hooks`, so an install drifts from the
source with no signal. This command closes that loop: pull the latest source, re-sync the files, and
PROVE the install matches source with the drift check. Then say what changed in one human paragraph.

This only ever writes to the Prism source clone (git) and the install dir under `~/.claude` (copies).
It never touches the user's project code. It is fully reversible via git in the clone.

## 1. Locate the source clone
The engine (`scripts/prism-update.sh`) lives in the clone, so you must find the clone first.
- If `~/.prism/config` exists and defines `PRISM_SOURCE=<path>` and that path holds `commands/prism.md`,
  use it.
- Else, if the current directory (or a parent) is a Prism clone (`commands/prism.md` + `VERSION`
  present), use that and save it: append `PRISM_SOURCE=<abspath>` to `~/.prism/config` so the next
  run is one step. (Create `~/.prism/` if missing.)
- Else, ask the user ONCE for the path to their `prism-claude-code` clone, verify it, and save it.
  If they have never cloned it, give them the two lines from the README (`git clone ...`) and stop.
State the resolved source path in one line before proceeding.

## 2. Preview (do not apply yet)
From the clone, show what an update would bring, without changing the install:
- `bash scripts/prism-version.sh --check` — current drift between source and `~/.claude/commands`.
- `git -C <clone> fetch --quiet && git -C <clone> log --oneline HEAD..@{u} -- commands hooks CHANGELOG.md`
  — commits waiting upstream (empty means the clone is already current).
- Read the top section of `CHANGELOG.md` for the human summary of the newest version.
If there is nothing upstream AND the drift check already says "in sync", tell the user they are up to
date, show the current version, and stop. Do not run the sync for no reason.

## 3. Apply
Run the engine and let it do the real work (pull, copy, verify):
```
bash <clone>/scripts/prism-update.sh
```
- Default target is `~/.claude`. If the user installed Prism into a specific PROJECT instead of the
  global dir, pass `--project <path>` (or `--commands-dir`/`--hooks-dir`).
- If the script reports it skipped the pull because of local edits to command/hook files, surface that
  verbatim. Do NOT pass `--force` on your own; ask the user, since forcing can discard their edits.
- If the fast-forward pull fails (diverged history), report it and stop; the user needs to reconcile
  the clone by hand. Never rebase or reset their clone for them.

## 4. Confirm + report
The engine ends with a drift check; read its exit.
- On "in sync": report the version bump (`before -> after`), and summarize what is new in one short
  human paragraph grounded in the CHANGELOG top entry and the pulled commit list. No slop, no em-dashes.
- On remaining drift (STALE entries from removed commands): explain that a command was removed upstream
  and offer to re-run with `--prune` to delete the stale installed copy. Do not prune without consent.
- Remind them once: reload slash commands (restart the Claude Code session) so the new versions load.

## Guardrails
- Reversible only: git in the clone, file copies in `~/.claude`. Never write to the user's project.
- Never `--force` or prune without explicit consent; both can destroy user changes.
- Prove, do not assert: the "in sync" claim must come from the drift check, not from having run copy.
