# Changelog

Human-readable record of what changed between Prism versions. `/prism-update` reads the top entry
to tell you what is new after a sync. Newest first. No em-dashes.

## 0.2.0

Large-codebase support, craft floor, a docs command, and grounding upgrades.

- **Bigger codebases.** `/prism-understand` gained a size gate and a Repo Map (structure cache used
  as a navigation hint, never as authority; git-OID staleness). `/prism-implement` and `/prism-build`
  detect the nearest manifest in a monorepo so work stays scoped to the right package.
- **Craft floor.** `build` / `implement` / `ship` now hold a readability bar: intent-revealing names,
  one job per function, no dead code, comments that explain why. Code a human can modify.
- **New command `/prism-write`.** Grounded README, change summary, retroactive comments, or a clean
  self-contained HTML article with an architecture diagram. Human voice, no AI slop, no em-dashes.
- **W7 currency + audience grounding.** Every command now checks that named SDKs/APIs are current
  (not renamed or superseded) and, for outward-facing output, reads it as a domain expert would to
  catch overclaims, not just incorrect code.
- **Evidence tiers.** Claims are labeled verified / supported / unverified / contradicted; grounding
  outranks cross-tier survival.
- **Risk-tiered guard.** `prism-guard.sh` rewritten to block one-way doors and dangerous `rm` while
  allowing safe cases (`rm -rf node_modules`). 22-case test harness.
- **Update + drift tooling.** `scripts/prism-update.sh` (this) syncs a clone into your install and
  proves it with the drift check; `scripts/prism-version.sh --check` reports MISSING/DRIFTED/STALE.
- **New command `/prism-update`.** One command to pull the latest Prism and sync it into `~/.claude`.

## 0.1.0

Initial public playbook set: understand, plan, build, implement, ship, feedback, retro, prune, eval,
plus the deliberation engine (differential context, divergence score, cross-tier verification,
telemetry) and the zero-false-positive gate hook.
