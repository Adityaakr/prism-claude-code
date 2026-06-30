# Plan 04: The 9.8 gap, and what "done" means for each item

*Decision doc. `/prism-plan` on 2026-06-30. The honest scorecard behind docs/03, plus the objective*
*bar that turns each "planned" into "landed." Written without em-dashes.*

## The honest grade

Where Prism is right now:
- It looks more serious. It looks more disciplined. It looks more product-shaped.
- It reads like a smart, self-aware, fast-improving system with good taste.
- It does NOT yet read like a fully production-grade, battle-tested, category-defining system.

That gap is real and it is not a wording problem. It is a different KIND of bar.

## Why "planned" is not "done," and why features alone do not reach 9.8

Two different ladders are in play, and the second is the one Prism has barely started:

1. **Feature-complete** is buildable in a sprint. Write the playbook, commit the script, ship it.
   Most of docs/03 lives here.
2. **Battle-tested and category-defining** is EARNED, not built. It comes from sustained real use,
   accumulated evidence, and a public track record of failures caught and avoided. No amount of
   feature work grants it. It is downstream of running on many real repos, over time, with results
   anyone can check.

So the fastest credibility jump is not more features. It is converting claims into evidence: real
large-repo validation and a hardened, re-run eval. That is the part that has not happened.

## The eight gaps, each with its objective done-bar

The point of this table is the right column. "Planned" is not a state Prism gets credit for. A gap is
closed only when its evidence exists.

| # | Gap (as it stands today) | Work to land it | DONE means (the objective bar) |
|---|---|---|---|
| 1 | Monorepo orchestration is detected, not handled. Only manifest-root detection exists (eval Task 10 open, `eval/battery/battery.md:18`). | Per-package stack detection + nearest-manifest-wins build in `prism-build`/`prism-implement`. | `/prism-implement` runs green on a real TS-frontend + Rust-contract monorepo, building each package with its own toolchain in ONE run, no manual stack hints. The Task 10 fixture passes. |
| 2 | The Repo Map win is modest and mostly helps repeated runs. | Add ephemeral ctags retrieval + (conditionally) reranking on top of the map. | A retrieval eval on a large fixture shows map + ctags beats naive full-read on BOTH token cost and miss rate by a stated margin. If it does not, the feature was theater and gets cut. |
| 3 | These are playbook instructions, not a hardened runtime. | Build the parts that CAN be software: tiered guard, `checkpoint.json` writer, version/drift check, write-protocol lock, each with a tiny test. | Those four exist as committed, tested scripts invoked by the playbooks. HONEST CEILING: the orchestration itself stays prompt-defined because it rides Claude Code. That part is structural, not a bug to fix. Say so, do not pretend otherwise. |
| 4 | No live large-repo validation has happened. | Actually run `/prism-understand` and `/prism-implement` on 2-3 real open-source repos over ~1000 files. Record cost, correctness, and miss rate. | A documented validation run on a real >1000-file repo, with results: did it find the right code, at what token cost, what did it miss. This one cannot be faked or shortcut. It is the single biggest lever for "battle-tested," and it requires DOING, not planning. |
| 5 | Memory sharing semantics are unresolved. | Decide shared vs private, implement it, keep docs consistent (the OVERVIEW/gitignore contradiction is already fixed in docs). | A decision is made and `.gitignore` + docs agree. A second clone either reads the shared `project-model.md` (shared) or the privacy is explicit by design (private). No contradiction remains. |
| 6 | No version or drift check, only planned. | Version-stamp each command; add a `prism-version` / drift check. | Running an outdated copy emits a drift warning against source. Proof this matters: docs/03's first draft cited playbook line numbers that were already stale by ~15 lines. |
| 7 | No write protocol, only planned. Concurrent runs clobber memory. | A lock file or append-only protocol for `project-model.md`. | A test simulating two concurrent runs shows neither write is silently lost (one waits or both survive). |
| 8 | Evidence ladder + citation enforcement are still MVP work, not landed. | Implement the 4-tier convention in the playbooks + a citation-enforcing verifier. | Every load-bearing claim in a `/prism-plan` or `/prism-implement` output carries a tier tag; the grounding eval (precision/recall) passes on enforcement; a fixture shows uncited claims get struck or demoted. |

## The honest ceiling: what still keeps Prism below 9.8 even after all eight close

Closing the eight moves Prism from "smart, self-aware, fast-improving with good taste" to "disciplined,
hardened where it can be, and honestly measured." It does NOT by itself reach battle-tested or
category-defining. Four things still gate that, and three of them are not buildable:

1. **Battle-tested is a function of use, not features.** Prism has run its eval once (12 tasks, n=12,
   Wilson CI [0.19, 0.68], one judge, mostly its own internals). A track record is earned over many
   runs, many repos, and many users across months. No sprint grants it.
2. **The eval is thin.** Until it is hardened (>=25 tasks, dual/non-family judges, real-repo fixtures)
   and re-run, every quality claim stays "shrink-leaning, not proven" (`EVAL-REPORT.md`). The number
   is honest precisely because it is bounded; that honesty is also the ceiling.
3. **The substrate has limits.** The orchestration is prompt-defined and rides Claude Code. Hard token
   caps, true sandboxing, and deterministic execution are structurally out of reach from inside a
   prompt. A production-grade system states its substrate ceiling rather than papering over it.
4. **Category-defining is a market claim, not an engineering one.** It is downstream of others adopting
   the approach and validating it in public. No plan in this repo can grant it.

## Recommendation: the order that buys the most credibility per unit work

Do the evidence-converting work first, because it is what "production-grade" actually means here:

1. **Gap 8 (evidence tiers + citations)** and **Gap 5 (memory decision)**: cheap, playbook-level, and
   they make every other output more trustworthy. Land these in the MVP.
2. **Gap 4 (real large-repo validation)**: the biggest single jump from "looks serious" to "is tested."
   It also tells you whether Gap 1 and Gap 2 are even worth building, by exposing where Prism actually
   breaks on real scale. Do this BEFORE building more retrieval machinery.
3. **Harden and re-run the eval** (the docs/03 Section 12 fixtures): converts the headline from
   "shrink-leaning" to a defensible number, or tells you to shrink further.
4. **Gap 3 hardening scripts (guard, checkpoint, version, lock)** and then **Gap 1 (monorepo)** and
   **Gap 6/7**: build these once validation has shown they earn their cost.

The blunt version: stop building features for a beat and go RUN Prism on real repos and re-run the
eval. Evidence is the only thing that closes the distance between "good taste" and "battle-tested,"
and it is the one thing that cannot be written into a playbook.

## Open questions for the human
- Is `.prism/` team-shared or machine-private? Gates Gap 5 and the whole memory architecture.
- Which 2-3 real repos should the Gap 4 validation run against? That choice shapes what "tested" means.
- Is the goal actually 9.8, or is "honestly a strong 8.5 that knows its own limits" the more defensible
  position to hold publicly until the evidence exists? The second is more credible than claiming the first.

## Telemetry
- divergence: n/a single-pass synthesis (no fan-out; per the eval, design synthesis does not benefit
  from the fleet, and Section 8 of the source request explicitly rejects orchestration theater)
- models: draft=opus
- claims: gap inventory grounded against docs/03 + repo state (`.gitignore:5`, `eval/battery/battery.md:18`,
  `EVAL-REPORT.md`); the honest-ceiling claims are reasoned, labeled as judgment not measurement
- fleet: 0 (deliberate)
