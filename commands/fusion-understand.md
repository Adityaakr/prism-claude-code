---
description: Understand/map existing code or a concept — parallel explorers over each subsystem, synthesized into one coherent model with a file map. Read-only, fast.
allowed-tools: Task, Read, Grep, Glob, WebSearch, WebFetch, Write
---
# Fusion · Understand: $ARGUMENTS

You are the ORCHESTRATOR. Map the thing, don't guess. Run parallel explorers, then
synthesize ONE coherent model. Lead with a plain-language explanation.

## Steps
1. SCOPE: break the target into N parts (subsystems / files / concepts). State them in one line.
2. FAN-OUT (parallel, ONE message): launch one explorer subagent per part via Task, each
   with Read/Grep/Glob. Each returns a TIGHT map: what this part does, the key `file:line`
   anchors, and how it connects to the rest. No padding. (Give one agent WebSearch/WebFetch
   if the concept needs current external facts.) Diversity rule: no two explorers cover the
   same ground. Use ~3–6 explorers; scale to system size.
3. JUDGE: read all maps, reconcile overlaps/contradictions, and synthesize ONE model:
   - the end-to-end flow (step by step)
   - the data model / key types
   - the seams where you'd extend or change it
4. COMPLETENESS CRITIC: spawn one agent asking "what's missing, unread, or unexplained
   here?" — fold in what it finds.

## Output
- Lead with a PLAIN-LANGUAGE explanation a newcomer could follow.
- Then a FILE MAP table: area → key `file:line` → purpose.
- Then "where to touch it" for the most likely changes.
- Flag anything you could NOT confirm in the code (don't smooth it over).
- PERSIST only if the user asks: save to `docs/` as a new numbered file, never overwrite.
